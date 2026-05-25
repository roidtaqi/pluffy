<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'id',
    'user_id',
    'subtotal',
    'discount',
    'tax',
    'service_fee',
    'total',
    'status',
    'outlet_name',
    'payment_method',
    'voucher_code',
])]
class Order extends Model
{
    public $incrementing = false; // Primary key is a string (ORD-XXXX-YY)
    protected $keyType = 'string';

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }
}
