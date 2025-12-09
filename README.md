# H&M Product List
### Features

- Infinite Scroll Pagination.
- Two-Tier Image Caching - Memory (50MB) + Disk (100MB) caching for optimal performance
- Pull-to-Refresh - Intuitive gesture-based content refresh
- Comprehensive Accessibility - Full VoiceOver support, Dynamic Type, and accessibility labels
- Adaptive Layout - Responsive grid that adapts to device orientation and size
- Modern Concurrency - Built with async/await and Swift structured concurrency

### Key Architectural Decisions

- MVVM with Repositories - Clear separation between UI and business logic
- Protocol-Oriented Design - Easy to mock and test
- Swift Package Manager - Modular dependencies (NetworkEngine, CacheManager, Localisation)
- Dependency Injection - Explicit dependencies for testability

### Technical Highlights
#### Modern Swift Patterns

@Observable Macro (iOS 17+) - Modern state management replacing ObservableObject
- Async/Await - Structured concurrency throughout
- Actor Isolation - Thread-safe disk cache operations
- MainActor - Explicit UI thread isolation

#### Performance Optimizations

- Compressed Image Caching - Stores JPEG data (~1MB) instead of decoded UIImage (~32MB)
- Lazy Loading - LazyVGrid for efficient memory usage
- Background Decoding - Images decoded off main thread
- Request Deduplication - Prevents duplicate network calls for same image

#### Accessibility Features

- VoiceOver Labels - Comprehensive accessibility labels for all UI elements
- Dynamic Type - Supports text scaling
- Accessibility Traits - Proper button and interactive element marking
- Accessibility Hints - Contextual help for screen reader users
