<?php

namespace App\Http\Controllers;

use App\Models\Waitlist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class WaitlistController extends Controller
{
    public function index()
    {
        $waitlistCount = Waitlist::count();
        return view('waitlist', compact('waitlistCount'));
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|unique:waitlist,email',
            'cf-turnstile-response' => 'required'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first()
            ], 422);
        }

        // Verify Cloudflare Turnstile
        $turnstileResponse = $request->input('cf-turnstile-response');
        $secretKey = env('CLOUDFLARE_TURNSTILE_SECRET_KEY');
        
        if ($secretKey) {
            $verifyResponse = file_get_contents('https://challenges.cloudflare.com/turnstile/v0/siteverify', false, stream_context_create([
                'http' => [
                    'method' => 'POST',
                    'header' => 'Content-Type: application/x-www-form-urlencoded',
                    'content' => http_build_query([
                        'secret' => $secretKey,
                        'response' => $turnstileResponse,
                        'remoteip' => $request->ip()
                    ])
                ]
            ]));
            
            $verifyData = json_decode($verifyResponse, true);
            
            if (!$verifyData['success']) {
                return response()->json([
                    'success' => false,
                    'message' => 'Captcha is verifying your browser.. Please try again.'
                ], 422);
            }
        }

        try {
            Waitlist::create([
                'email' => $request->email,
                'ip_address' => $request->ip()
            ]);

            $newCount = Waitlist::count();

            return response()->json([
                'success' => true,
                'message' => 'Thank you! You\'ve been added to our waitlist.',
                'count' => $newCount
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Something went wrong. Please try again.'
            ], 500);
        }
    }
}
