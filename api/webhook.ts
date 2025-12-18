import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';
import { buffer } from 'micro';

export const config = {
  api: {
    bodyParser: false,
  },
};

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2025-02-24.acacia',
});

const supabase = createClient(
  process.env.VITE_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  const buf = await buffer(req);
  const sig = req.headers['stripe-signature'];

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(buf, sig as string, webhookSecret);
  } catch (err: any) {
    console.error(`Webhook signature verification failed: ${err.message}`);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as Stripe.Checkout.Session;
    const userId = session.client_reference_id;

    if (userId) {
      console.log(`Processing payment for user: ${userId}`);
      
      try {
        // 1. Update User to Pro
        const { error: updateError } = await supabase
          .from('users')
          .update({ is_pro: true })
          .eq('id', userId);

        if (updateError) throw updateError;

        // 2. Create Order Record
        // Check if order already exists (idempotency)
        // We can rely on payment_intent as a unique key if needed, but here just insert
        const { error: orderError } = await supabase
          .from('orders')
          .insert({
            user_id: userId,
            amount: session.amount_total ? session.amount_total / 100 : 0,
            status: 'completed',
            // provider_payment_id: session.payment_intent as string // If we had this column
          });

        if (orderError) throw orderError;

        console.log(`Successfully upgraded user ${userId} to Pro.`);
      } catch (error) {
        console.error('Error updating database:', error);
        res.status(500).send('Database Error');
        return;
      }
    }
  }

  res.status(200).json({ received: true });
}
