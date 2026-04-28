// Supabase Edge Function: DNA CRUD endpoint
// Route idea:
// POST   /dna    -> create/update brand DNA
// GET    /dna    -> get active brand DNA milik user

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;

Deno.serve(async (req) => {
  const authHeader = req.headers.get('Authorization') || '';
  const client = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } }
  });

  const { data: authData } = await client.auth.getUser();
  const user = authData?.user;
  if (!user) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });

  if (req.method === 'GET') {
    const { data, error } = await client
      .from('brands')
      .select('*')
      .eq('owner_id', user.id)
      .eq('is_active', true)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 400 });
    return new Response(JSON.stringify({ data }), { status: 200 });
  }

  if (req.method === 'POST' || req.method === 'PUT') {
    const body = await req.json();
    const row = {
      owner_id: user.id,
      dna_mode: body.dna_mode || 'brand',
      brand_name: body.brand_name,
      niche: body.niche || null,
      primary_offer: body.primary_offer || null,
      target_audience: body.target_audience || null,
      dna_profile: body.dna_profile || {},
      is_active: true
    };

    const { data, error } = await client.from('brands').upsert(row).select().single();
    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 400 });
    return new Response(JSON.stringify({ data }), { status: 200 });
  }

  return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 });
});
