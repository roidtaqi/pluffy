<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::firstOrCreate([
            'email' => 'roidtaqi@pluffy.cafe',
        ], [
            'name' => 'Roid Taqi',
            'password' => bcrypt(env('PLUFFY_DEMO_USER_PASSWORD', Str::password(24))),
            'loyalty_points' => 350,
            'loyalty_stamps' => 4,
            'membership_tier' => 'Gold Member',
        ]);

        $this->call([
            ProductSeeder::class,
        ]);
    }
}
