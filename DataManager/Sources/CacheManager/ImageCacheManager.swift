//
//  ImageCacheManager.swift
//  DataManager
//
//  Created by Aravind Vijayan on 2025-12-08.
//
//  Two-tier image caching: Memory (UIImage) + Disk (Data)
//  Caches decoded UIImage for performance, returns SwiftUI Image to views
//

import SwiftUI
import Foundation
import NetworkEngine

public final class ImageCacheManager: @unchecked Sendable {
    public static let shared = ImageCacheManager()

    // Memory cache - stores compressed JPEG Data for better memory efficiency
    private let memoryCache = NSCache<NSString, NSData>()
    private let memoryCacheQueue = DispatchQueue(label: "com.hm.memoryCache", attributes: .concurrent)

    // Disk cache
    private let diskCache: DiskCache

    // Network service for downloading
    private let networkService: NetworkService

    // Track active downloads to prevent duplicate requests
    private var activeDownloads: [String: Task<Image?, Never>] = [:]
    private let downloadQueue = DispatchQueue(label: "com.hm.imageCache", attributes: .concurrent)

    init(networkService: NetworkService = DefaultNetworkService()) {
        self.networkService = networkService

        // Configure memory cache - stores compressed Data
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB - can hold ~50 compressed images
        memoryCache.countLimit = 100

        // Initialize disk cache
        diskCache = DiskCache()

        // Listen for memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    @objc private func handleMemoryWarning() {
        memoryCacheQueue.async(flags: .barrier) { [weak self] in
            self?.memoryCache.removeAllObjects()
            print("Memory cache cleared due to memory warning")
        }
    }

    // Thread-safe memory cache access
    private func getCachedData(forKey key: String) -> Data? {
        return memoryCacheQueue.sync {
            let cached = memoryCache.object(forKey: key as NSString) as Data?
            if cached != nil {
                print("Memory cache HIT: \(key)")
            } else {
                print("Memory cache MISS: \(key)")
            }
            return cached
        }
    }

    // Thread-safe memory cache storage - stores compressed Data
    private func cacheData(_ data: Data, forKey key: String) {
        memoryCacheQueue.sync(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.memoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
            print("Stored in memory cache: \(key) (cost: \(data.count) bytes)")
        }
    }

    // Returns SwiftUI Image for views
    public func loadImage(from urlString: String) async -> Image? {
        print("Loading image: \(urlString)")

        // Step 1: Check memory cache for compressed data
        if let cachedData = getCachedData(forKey: urlString),
           let uiImage = await decodeUIImage(from: cachedData) {
            return Image(uiImage: uiImage)
        }

        // Step 2: Check disk cache
        if let data = await diskCache.data(forKey: urlString),
           let uiImage = await decodeUIImage(from: data) {
            print("Image found in diskCache: \(urlString)")
            // Promote to memory cache
            cacheData(data, forKey: urlString)
            return Image(uiImage: uiImage)
        }

        // Step 3: Check if already downloading
        let existingTask = downloadQueue.sync {
            return activeDownloads[urlString]
        }

        if let task = existingTask {
            print("Already downloading, waiting for result: \(urlString)")
            return await task.value
        }

        // Step 4: Download from network using NetworkService
        let downloadTask = Task<Image?, Never> {
            guard let url = URL(string: urlString) else {
                print("Invalid URL: \(urlString)")
                return nil
            }

            print("Starting download: \(urlString)")

            // Use NetworkService instead of URLSession directly
            guard let data = try? await self.networkService.downloadData(from: url),
                  let uiImage = await self.decodeUIImage(from: data) else {
                print("Download or decode failed: \(urlString)")
                return nil
            }

            print("Downloaded and decoded: \(urlString)")

            // Cache the compressed Data (not the decoded UIImage)
            self.cacheData(data, forKey: urlString)

            // Verify it was cached
            if let verify = self.getCachedData(forKey: urlString) {
                print("Verified in cache after storing: \(urlString)")
            } else {
                print("NOT in cache after storing (this is a bug!): \(urlString)")
            }

            // Save to disk
            await self.diskCache.save(data, forKey: urlString)

            // Remove from active downloads
            self.downloadQueue.async(flags: .barrier) { [weak self] in
                self?.activeDownloads.removeValue(forKey: urlString)
            }

            return Image(uiImage: uiImage)
        }

        // Store active download task
        downloadQueue.async(flags: .barrier) { [weak self] in
            self?.activeDownloads[urlString] = downloadTask
        }

        return await downloadTask.value
    }

    // Decode image on background thread to prevent main thread blocking
    private func decodeUIImage(from data: Data) async -> UIImage? {
        return await Task.detached(priority: .userInitiated) {
            guard let image = UIImage(data: data),
                  let cgImage = image.cgImage else {
                return nil
            }

            // Force decode to avoid lazy decoding on main thread
            let width = cgImage.width
            let height = cgImage.height
            let colorSpace = CGColorSpaceCreateDeviceRGB()

            guard let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
            ) else {
                return image
            }

            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            context.draw(cgImage, in: rect)

            guard let decodedCGImage = context.makeImage() else {
                return image
            }

            return UIImage(
                cgImage: decodedCGImage,
                scale: image.scale,
                orientation: image.imageOrientation
            )
        }.value
    }
}

// MARK: - Disk Cache
actor DiskCache {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let maxDiskCacheSize: Int = 100 * 1024 * 1024 // 100 MB

    init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache", isDirectory: true)

        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func data(forKey key: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent(key.safeFilename)
        return try? Data(contentsOf: fileURL)
    }

    func save(_ data: Data, forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key.safeFilename)
        try? data.write(to: fileURL)

        // Clean up old files if cache is too large
        Task {
            await cleanUpIfNeeded()
        }
    }

    private func cleanUpIfNeeded() {
        guard let files = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
        ) else {
            return
        }

        let filesWithAttributes = files.compactMap { url -> (URL, Int, Date)? in
            guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
                  let size = attributes[.size] as? Int,
                  let modificationDate = attributes[.modificationDate] as? Date else {
                return nil
            }
            return (url, size, modificationDate)
        }

        let totalSize = filesWithAttributes.reduce(0) { $0 + $1.1 }

        if totalSize > maxDiskCacheSize {
            // Sort by modification date (oldest first)
            let sortedFiles = filesWithAttributes.sorted { $0.2 < $1.2 }

            var currentSize = totalSize
            for (url, size, _) in sortedFiles {
                if currentSize <= maxDiskCacheSize / 2 { break }
                try? fileManager.removeItem(at: url)
                currentSize -= size
            }

            print("Disk cache cleaned up: removed \(totalSize - currentSize) bytes")
        }
    }
}

// MARK: - String Extension for Safe Filenames
extension String {
    /// Converts a URL string to a safe filename
    /// Uses base64 encoding with unsafe characters replaced
    var safeFilename: String {
        // Convert to data and base64 encode
        guard let data = self.data(using: .utf8) else {
            // Fallback: just replace unsafe characters
            return self
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: ":", with: "_")
                .replacingOccurrences(of: "?", with: "_")
                .replacingOccurrences(of: "&", with: "_")
        }

        // Base64 encode and make it filename-safe
        return data.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }
}
