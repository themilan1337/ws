import './bootstrap';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

// Register GSAP plugins
gsap.registerPlugin(ScrollTrigger);

// Make GSAP available globally
window.gsap = gsap;
window.ScrollTrigger = ScrollTrigger;

// Waitlist form functionality
document.addEventListener('DOMContentLoaded', function() {
    // Initialize animations
    initAnimations();
    
    // Initialize countdown
    initCountdown();
    
    // Initialize form
    initWaitlistForm();
});

function initAnimations() {
    // Hero section animations
    gsap.timeline()
        .from('.hero-title', { duration: 1, y: 50, opacity: 0, ease: 'power3.out' })
        .from('.hero-subtitle', { duration: 1, y: 30, opacity: 0, ease: 'power3.out' }, '-=0.5')
        .from('.hero-form', { duration: 1, y: 30, opacity: 0, ease: 'power3.out' }, '-=0.3')
        .from('.floating-elements', { duration: 1, scale: 0, opacity: 0, ease: 'back.out(1.7)' }, '-=0.5');
    
    // Floating elements animation
    gsap.to('.floating-circle', {
        y: -20,
        duration: 3,
        ease: 'power1.inOut',
        yoyo: true,
        repeat: -1,
        stagger: 0.5
    });
    
    // Stats counter animation
    ScrollTrigger.create({
        trigger: '.stats-section',
        start: 'top 80%',
        onEnter: () => {
            animateCounter('.waitlist-count', parseInt(document.querySelector('.waitlist-count').textContent));
        }
    });
}

function initCountdown() {
    const targetDate = new Date('July 1, 2025 00:00:00').getTime();
    
    function updateCountdown() {
        const now = new Date().getTime();
        const distance = targetDate - now;
        
        if (distance > 0) {
            const days = Math.floor(distance / (1000 * 60 * 60 * 24));
            const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            document.getElementById('days').textContent = days.toString().padStart(2, '0');
            document.getElementById('hours').textContent = hours.toString().padStart(2, '0');
            document.getElementById('minutes').textContent = minutes.toString().padStart(2, '0');
            document.getElementById('seconds').textContent = seconds.toString().padStart(2, '0');
        }
    }
    
    updateCountdown();
    setInterval(updateCountdown, 1000);
}

function initWaitlistForm() {
    const form = document.getElementById('waitlist-form');
    const emailInput = document.getElementById('email');
    const submitBtn = document.getElementById('submit-btn');
    const messageDiv = document.getElementById('message');
    
    if (form) {
        form.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const email = emailInput.value.trim();
            const turnstileResponse = document.querySelector('[name="cf-turnstile-response"]')?.value;
            
            if (!email) {
                showMessage('Please enter your email address.', 'error');
                return;
            }
            
            if (!turnstileResponse) {
                showMessage('Please complete the captcha.', 'error');
                return;
            }
            
            submitBtn.disabled = true;
            submitBtn.textContent = 'Joining...';
            
            try {
                const response = await fetch('/waitlist', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    },
                    body: JSON.stringify({
                        email: email,
                        'cf-turnstile-response': turnstileResponse
                    })
                });
                
                const data = await response.json();
                
                if (data.success) {
                    showMessage(data.message, 'success');
                    emailInput.value = '';
                    
                    // Update counter with animation
                    const counterElement = document.querySelector('.waitlist-count');
                    if (counterElement) {
                        animateCounter('.waitlist-count', data.count);
                    }
                    
                    // Success animation
                    gsap.to(form, { scale: 1.05, duration: 0.2, yoyo: true, repeat: 1 });
                } else {
                    showMessage(data.message, 'error');
                }
            } catch (error) {
                showMessage('Something went wrong. Please try again.', 'error');
            } finally {
                submitBtn.disabled = false;
                submitBtn.textContent = 'Join Waitlist';
                
                // Reset Turnstile
                if (window.turnstile) {
                    window.turnstile.reset();
                }
            }
        });
    }
}

function showMessage(message, type) {
    const messageDiv = document.getElementById('message');
    if (messageDiv) {
        messageDiv.textContent = message;
        messageDiv.className = `message ${type}`;
        messageDiv.style.display = 'block';
        
        // Animate message
        gsap.fromTo(messageDiv, 
            { opacity: 0, y: -10 },
            { opacity: 1, y: 0, duration: 0.3 }
        );
        
        // Hide after 5 seconds
        setTimeout(() => {
            gsap.to(messageDiv, {
                opacity: 0,
                y: -10,
                duration: 0.3,
                onComplete: () => {
                    messageDiv.style.display = 'none';
                }
            });
        }, 5000);
    }
}

function animateCounter(selector, targetValue) {
    const element = document.querySelector(selector);
    if (element) {
        gsap.to({ value: parseInt(element.textContent) || 0 }, {
            value: targetValue,
            duration: 2,
            ease: 'power2.out',
            onUpdate: function() {
                element.textContent = Math.round(this.targets()[0].value);
            }
        });
    }
}