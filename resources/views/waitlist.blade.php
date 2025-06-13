<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>SereneAI - AI-Powered Mental Wellness | Coming Soon</title>
    <meta name="description" content="SereneAI - the revolutionary AI-powered platform for personalized meditation, affirmations, and gratitude practices.">
    <meta content="meditation, ai meditation, ai meditation app, serene ai, serenepal, serenepal ai, serenepal.com, serene meditation, serene meditation app" name=keywords>
    <meta content="AI-Driven meditation app. Generate meditations, affirmations and more using AI!" name=description>
    <meta content="index, follow, max-snippet: -1, max-image-preview:large, max-video-preview: -1" name=robots>
    <!-- Cloudflare Turnstile -->
    <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
    
    @vite(['resources/css/app.css','resources/css/base.css', 'resources/js/app.js'])
</head>
<body class="bg-gradient-to-br from-sky-50 via-white to-indigo-50 min-h-screen">
    <!-- Header -->
    <header class="relative z-10 px-6 py-4">
        <nav class="max-w-7xl mx-auto flex items-center justify-between">
            <div class="flex items-center space-x-2">
                <div class="my-auto h-12 overflow-hidden">
                    <img src="{{ asset('images/logo.png') }}" alt="SereneAI Logo" class="w-full h-full object-cover">
                </div>
            </div>
            <div class="hidden md:flex items-center space-x-6">
                <a href="#features" class="text-gray-600 hover:text-sky-600 transition-colors">Features</a>
                <a href="#about" class="text-gray-600 hover:text-sky-600 transition-colors">About</a>
                <a href="#waitlist" class="bg-gradient-to-r from-sky-400 to-sky-500 text-white px-8 py-2 rounded-full transition-all active:scale-95">Join Waitlist</a>
            </div>
        </nav>
    </header>

    <!-- Floating Background Elements -->
    <div class="floating-elements fixed inset-0 pointer-events-none overflow-hidden">
        <div class="floating-circle absolute top-20 left-10 w-32 h-32 bg-sky-200 rounded-full opacity-20"></div>
        <div class="floating-circle absolute top-40 right-20 w-24 h-24 bg-indigo-200 rounded-full opacity-30"></div>
        <div class="floating-circle absolute bottom-32 left-1/4 w-40 h-40 bg-pink-200 rounded-full opacity-15"></div>
        <div class="floating-circle absolute bottom-20 right-10 w-28 h-28 bg-blue-200 rounded-full opacity-25"></div>
    </div>

    <!-- Hero Section -->
    <main class="relative z-10">
        <section class="px-6 py-20 text-center">
            <div class="max-w-4xl mx-auto">

                <a href="https://nfactorial.school/">
                    <div class="inline-flex items-center gap-2 px-4 py-2 border border-gray-200 rounded-full text-sm font-medium text-muted-foreground mx-auto mb-8">
                        <span>Backed by</span>
                        <img 
                            alt="nFactorial Logo" 
                            loading="lazy" 
                            width="20" 
                            height="20" 
                            class="h-5 w-5 object-contain" 
                            src="{{ asset('images/n.jpeg') }}"
                        >
                        <span>nFactorial</span>
                    </div>
                </a>

                <h1 class="hero-title text-5xl md:text-7xl font-bold mb-6 blacker">
                    <span class="bg-gradient-to-r from-sky-600 to-sky-700 bg-clip-text text-transparent">
                        AI-Powered
                    </span>
                    <br>
                    <span class="text-gray-800">Mental Wellness</span>
                </h1>
                
                <p class="hero-subtitle text-xl md:text-2xl text-gray-600 mb-12 max-w-3xl mx-auto leading-relaxed">
                    Experience personalized meditation, affirmations, and gratitude practices tailored just for you. 
                    Our AI creates unique content based on your goals, mood, and needs.
                </p>

                <!-- Countdown Timer -->
                <div class="hero-form mb-16">
                    <h3 class="text-2xl font-semibold text-gray-800 mb-8">Launching in</h3>
                    <div class="flex justify-center space-x-4 md:space-x-8 mb-12">
                        <div class="text-center">
                            <div class="border border-gray-300 rounded-4xl p-4 md:p-6 min-w-[80px] md:min-w-[100px]">
                                <div id="days" class="text-3xl md:text-4xl font-bold text-sky-600">00</div>
                                <div class="text-sm text-gray-500 uppercase tracking-wide">Days</div>
                            </div>
                        </div>
                        <div class="text-center">
                            <div class="border border-gray-300 rounded-4xl p-4 md:p-6 min-w-[80px] md:min-w-[100px]">
                                <div id="hours" class="text-3xl md:text-4xl font-bold text-sky-600">00</div>
                                <div class="text-sm text-gray-500 uppercase tracking-wide">Hours</div>
                            </div>
                        </div>
                        <div class="text-center">
                            <div class="border border-gray-300 rounded-4xl p-4 md:p-6 min-w-[80px] md:min-w-[100px]">
                                <div id="minutes" class="text-3xl md:text-4xl font-bold text-sky-600">00</div>
                                <div class="text-sm text-gray-500 uppercase tracking-wide">Minutes</div>
                            </div>
                        </div>
                        <div class="text-center">
                            <div class="border border-gray-300 rounded-4xl p-4 md:p-6 min-w-[80px] md:min-w-[100px]">
                                <div id="seconds" class="text-3xl md:text-4xl font-bold text-sky-600">00</div>
                                <div class="text-sm text-gray-500 uppercase tracking-wide">Seconds</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Waitlist Form -->
                <div id="waitlist" class="hero-form max-w-md mx-auto">
                    <div class="border border-gray-300 rounded-2xl p-8">
                        <h3 class="text-2xl font-semibold text-gray-800 mb-6">Join the Waitlist</h3>
                        
                        <div id="message" class="message hidden mb-4 p-3 rounded-full text-sm" style="margin-top:10px;margin-bottom:10px;border-radius:100px;padding-top:5px;padding-bottom:5px;"></div>
                        
                        <form id="waitlist-form" class="space-y-4">
                            @csrf
                            <div>
                                <input 
                                    type="email" 
                                    id="email" 
                                    name="email" 
                                    placeholder="Enter your email address"
                                    class="w-full outline-none px-4 py-3 border border-gray-300 rounded-full text-center focus:ring-2 focus:ring-sky-500 focus:border-transparent transition-all"
                                    required
                                >
                            </div>
                            
                            <!-- Cloudflare Turnstile -->
                            <div class="cf-turnstile" data-sitekey="0x4AAAAAABg-d5NxCTkGkfz-" data-theme="light"></div>
                            
                            <button 
                                type="submit" 
                                id="submit-btn"
                                class="w-full bg-sky-500 text-white py-3 px-6 rounded-full font-semibold transform transition-all duration-100 cursor-pointer active:scale-95 active:shadow-sm"
                            >
                                Join Waitlist
                            </button>
                        </form>
                        
                        <div class="mt-6 text-center">
                            <p class="text-sm text-gray-500">
                                <span class="waitlist-count font-semibold text-sky-600">{{ $waitlistCount }}</span> 
                                people have already joined
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Features Section -->
        <section id="features" class="px-6 py-20 bg-white">
            <div class="max-w-6xl mx-auto">
                <h2 class="text-4xl font-bold text-center text-gray-800 mb-16">
                    Personalized Wellness, Powered by AI
                </h2>
                
                <div class="grid md:grid-cols-3 gap-8">
                    <div class="text-center p-6">
                        <div class="w-16 h-16 bg-sky-500 rounded-full flex items-center justify-center mx-auto mb-6">
                            <svg class="w-8 h-8 text-white" xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"><!-- Icon from Huge Icons by Hugeicons - undefined --><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" color="currentColor"><path d="M7.886 10c.686 1.397 1.418 2.705 1.25 4.314c-.271 2.573-3.39 3.541-5.386 4.726c-1.307.777-.818 2.96.786 2.96c1.944 0 3.68-.155 5.435-.98l3.44-2.117c.478-.225 1.08-.129 1.589.097"/><path d="M16.01 10c-.7 1.397-1.448 2.705-1.275 4.314c.276 2.573 3.462 3.541 5.499 4.726c1.334.777.835 2.96-.802 2.96c-1.986 0-3.759-.155-5.55-.98l-3.514-2.117c-.41-.189-.91-.151-1.368 0M10 4a2 2 0 1 0 4 0a2 2 0 0 0-4 0"/><path d="M3 16c2.446 0 3.544-2.705 3.893-4.57c.092-.488.24-.973.563-1.349A5.99 5.99 0 0 1 12 8c1.816 0 3.444.807 4.544 2.081c.323.376.471.861.563 1.348C17.457 13.295 18.554 16 21 16"/></g></svg>
                        </div>
                        <h3 class="text-xl font-semibold text-gray-800 mb-4">Personalized Affirmations</h3>
                        <p class="text-gray-600">AI-generated affirmations tailored to your specific goals, mood, and desired qualities.</p>
                    </div>
                    
                    <div class="text-center p-6">
                        <div class="w-16 h-16 bg-sky-500 rounded-full flex items-center justify-center mx-auto mb-6">
                            <svg class="w-8 h-8 text-white" xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"><!-- Icon from Huge Icons by Hugeicons - undefined --><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" color="currentColor"><path d="m10.506 15.009l6.634-4.511q.283-.211.497-.488c.485-.63.476-1.506.168-2.238A4.55 4.55 0 0 0 13.6 5c-.936 0-1.806.279-2.529.757l-7.08 5"/><path d="M5.995 13.506c0 .696.369 2.08 2.04 2.46c1.007.228 3.938-.736 2.504-3.528s-4.887-2.806-6.292-1.87c-.859.52-2.526 2.148-2.21 4.311c.113 1.31 1.145 3.97 4.375 4.122h9.892c.922-.073 1.112-.207 1.814-.745c.945-.848 2.522-2.408 3.439-3.435c.198-.221.411-.45.439-.746v0c.145-1.576-2.247-.893-3.98-1.081"/></g></svg>
                        </div>
                        <h3 class="text-xl font-semibold text-gray-800 mb-4">Custom Meditations</h3>
                        <p class="text-gray-600">Unique meditation sessions adapted to your preferred duration, theme, and current state of mind.</p>
                    </div>
                    
                    <div class="text-center p-6">
                        <div class="w-16 h-16 bg-sky-500 rounded-full flex items-center justify-center mx-auto mb-6">
                            <svg class="w-8 h-8 text-white" xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"><!-- Icon from Huge Icons by Hugeicons - undefined --><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" color="currentColor"><path d="M9 10c0 3.866 3 7 3 7s3-3.134 3-7s-3-7-3-7s-3 3.134-3 7"/><path d="M6.33 8C4.115 7.046 2 7 2 7s.096 4.381 2.857 7.143S12 17 12 17s4.381-.096 7.143-2.857S22 7 22 7s-2.114.046-4.33 1m-5.65 9c-.166 1.333.64 4 3.494 4c1.995 0 2.993-2 6.486 0c-.4-2-1.2-3.28-2.367-4m-7.654 0c.167 1.333-.64 4-3.492 4C6.49 21 5.493 19 2 21c.4-2 1.2-3.28 2.367-4"/></g></svg>
                        </div>
                        <h3 class="text-xl font-semibold text-gray-800 mb-4">Gratitude practices</h3>
                        <p class="text-gray-600">Personalized gratitude exercises and journal prompts based on your life experiences and mindset.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- About Section -->
        <section id="about" class="px-6 py-20 bg-gradient-to-br from-sky-50 to-indigo-50">
            <div class="max-w-4xl mx-auto text-center">
                <h2 class="text-4xl font-bold text-gray-800 mb-8">
                    The Future of Mental Wellness
                </h2>
                <p class="text-lg text-gray-600 mb-8 leading-relaxed">
                    SereneAI revolutionizes mental wellness by combining artificial intelligence with proven mindfulness practices. 
                    Instead of generic content, our platform creates unique, personalized experiences that evolve with your journey.
                </p>
                <p class="text-lg text-gray-600 leading-relaxed">
                    Whether you're seeking stress relief, better focus, or emotional balance, SereneAI adapts to your needs, 
                    providing content that resonates with your current state and helps you achieve your wellness goals.
                </p>
            </div>
        </section>

        <!-- Stats Section -->
        <section class="stats-section px-6 py-16 bg-white">
            <div class="max-w-4xl mx-auto text-center">
                <div class="grid md:grid-cols-3 gap-8">
                    <div>
                        <div class="text-4xl font-bold text-sky-600 mb-2 waitlist-count">{{ $waitlistCount }}</div>
                        <div class="text-gray-600">Early Adopters</div>
                    </div>
                    <div>
                        <div class="text-4xl font-bold text-indigo-600 mb-2">AI</div>
                        <div class="text-gray-600">Powered Content</div>
                    </div>
                    <div>
                        <div class="text-4xl font-bold text-sky-600 mb-2">24/7</div>
                        <div class="text-gray-600">Personalized Support</div>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <!-- Footer -->
    <footer class="bg-gray-900 text-white px-6 py-12">
        <div class="max-w-6xl mx-auto text-center">
            <div class="flex items-center justify-center space-x-2 mb-6">
            <div class="my-auto h-12 overflow-hidden">
                    <img src="{{ asset('images/logow.png') }}" alt="SereneAI Logo" class="w-full h-full object-cover">
                </div>
            </div>
            <p class="text-gray-400 mb-6">
                AI-powered mental wellness platform for personalized meditation, affirmations, and gratitude practices.
            </p>
            <p class="text-sm text-gray-500">
                © 2024 SereneAI. All rights reserved. | Launching July 1st, 2025
            </p>
        </div>
    </footer>

    <style>
        .message {
            display: none;
        }
        .message.success {
            background-color: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }
        .message.error {
            background-color: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }
    </style>
</body>
</html>