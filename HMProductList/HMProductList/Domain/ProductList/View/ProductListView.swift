//
//  ProductListView.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-09.
//


import SwiftUI
import Localisation

struct ProductListView: View {
    @State var viewModel: ProductListViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    // MARK: - Layout
    private var columns: [GridItem] {
        let isLandscape = verticalSizeClass == .compact ||
        (horizontalSizeClass == .regular && verticalSizeClass == .regular)

        let columnCount = isLandscape ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount)
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle(UIStrings.productListTile.localized)
            .navigationBarTitleDisplayMode(.large)
            .task {
                if viewModel.products.isEmpty {
                    await viewModel.loadProducts()
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Content
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.products.isEmpty {
            ProgressView()
                .accessibilityLabel(UIStrings.loadingProducts.localized)
        } else if let error = viewModel.errorMessage, viewModel.products.isEmpty {
            ErrorView(message: error) {
                Task { await viewModel.loadProducts() }
            }
        } else if !viewModel.products.isEmpty {
            productGridView
        } else {
            Text("No products found")
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Grid
    private var productGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                // Use indices instead of product IDs to avoid duplicate ID errors
                ForEach(Array(viewModel.products.enumerated()), id: \.offset) { index, product in
                    ProductCardView(product: product, repository: viewModel.repository)
                }

                paginationFooter
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Pagination Footer
    @ViewBuilder
    private var paginationFooter: some View {
        if viewModel.isLoading && !viewModel.products.isEmpty {
            ProgressView()
                .padding()
                .accessibilityLabel(UIStrings.loadingMoreProducts.localized)
                .gridCellColumns(columns.count)

        } else if let error = viewModel.errorMessage, !viewModel.products.isEmpty {
            paginationErrorBanner(error)

        } else if viewModel.hasMorePages {
            Color.clear
                .frame(height: 1)
                .id("pagination-trigger")
                .gridCellColumns(columns.count)
                .onAppear {
                    Task {
                        await viewModel.loadMoreProductsIfNeeded()
                    }
                }
        }
    }

    private func paginationErrorBanner(_ message: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)

                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button(UIStrings.retry.localized) {
                    Task { await viewModel.loadMoreProducts() }
                }
                .font(.caption.weight(.semibold))
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
        .gridCellColumns(columns.count)
        .padding(.horizontal)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: retryAction) {
                Text(UIStrings.retry.localized)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: 200)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .accessibilityLabel(UIStrings.retry.localized)
            .accessibilityHint(UIStrings.retryHint.localized)
        }
        .padding()
    }
}
