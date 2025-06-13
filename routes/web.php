<?php

use App\Http\Controllers\WaitlistController;
use Illuminate\Support\Facades\Route;

Route::get('/', [WaitlistController::class, 'index'])->name('waitlist.index');
Route::post('/waitlist', [WaitlistController::class, 'store'])->name('waitlist.store');
