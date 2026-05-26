<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $casts = [
        'base_price' => 'integer',
        'rating' => 'float',
        'stock' => 'integer',
        'is_best_seller' => 'boolean',
        'is_seasonal' => 'boolean',
        'is_active' => 'boolean',
    ];

    protected $fillable = [
        'name',
        'description',
        'base_price',
        'category',
        'image_url',
        'rating',
        'availability_status',
        'stock',
        'is_best_seller',
        'is_seasonal',
        'is_active',
    ];
}
