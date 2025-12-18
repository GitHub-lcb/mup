import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2025-02-24.acacia', // Use latest API version or valid one
});

// Admin Supabase client to verify users
const supabase = createClient(
  process.env.VITE_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method Not Allowed' });
    return;
  }

  try {
    const { priceId, successUrl, cancelUrl, token } = req.body;

    // 1. Verify User
    const { data: { user }, error } = await supabase.auth.getUser(token);
    
    if (error || !user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // 2. Create Checkout Session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card', 'alipay'],
      line_items: [
        {
          price_data: {
            currency: 'cny',
            product_data: {
              name: 'Pro Membership (Lifetime)',
              description: 'Unlock all premium questions and features forever.',
              images: ['https://mup.lichenbo.cn/favicon.svg'], // Optional
            },
            unit_amount: 9900, // 99.00 CNY
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: successUrl,
      cancel_url: cancelUrl,
      client_reference_id: user.id, // Pass user ID to webhook
      metadata: {
        userId: user.id,
      },
    });

    res.status(200).json({ sessionId: session.id, url: session.url });
  } catch (err: any) {
    console.error('Stripe Error:', err);
    res.status(500).json({ error: err.message });
  }
}
