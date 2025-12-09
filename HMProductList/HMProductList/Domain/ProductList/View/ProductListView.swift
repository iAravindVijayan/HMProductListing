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

    // MARK: - Computed Properties
    // Adaptive columns based on orientation
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
                // Background color
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.products.isEmpty {
                    // Initial loading
                    ProgressView()
                        .accessibilityLabel(UIStrings.loadingProducts.localized)
                } else if let error = viewModel.errorMessage, viewModel.products.isEmpty {
                    // Error state (only show when no products loaded)
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadProducts()
                        }
                    }
                } else {
                    // Product grid
                    productGridView
                }
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

    // MARK: - Subviews
    private var productGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.products) { product in
                    ProductCardView(product: product, repository: viewModel.repository)
                        .onAppear {
                            // Pagination trigger
                            Task {
                                await viewModel.loadMoreIfNeeded(currentProduct: product)
                            }
                        }
                }

                // Loading indicator for pagination
                if viewModel.isLoading {
                    ProgressView()
                        .gridCellColumns(columns.count)
                        .padding()
                        .accessibilityLabel(UIStrings.loadingMoreProducts.localized)
                }

                // Error banner for pagination errors (non-blocking)
                if let error = viewModel.errorMessage, !viewModel.products.isEmpty {
                    paginationErrorBanner(error)
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
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
                    Task {
                        await viewModel.loadNextPage()
                    }
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
