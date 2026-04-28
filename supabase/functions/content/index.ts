// Supabase Edge Function: Content CRUD endpoint
// POST   /content -> create content
// GET    /content?brand_id=... -> list content
// PATCH  /content?id=... -> update
// DELETE /content?id=... -> delete

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

  const url = new URL(req.url);

  if (req.method === 'GET') {
    const brandId = url.searchParams.get('brand_id');
    if (!brandId) return new Response(JSON.stringify({ error: 'brand_id is required' }), { status: 400 });

    const { data, error } = await client
      .from('content_ideas')
      .select('*')
      .eq('brand_id', brandId)
      .order('created_at', { ascending: false });

    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 400 });
    return new Response(JSON.stringify({ data }), { status: 200 });
  }

  if (req.method === 'POST') {
    const body = await req.json();
    const { data, error } = await client
      .from('content_ideas')
      .insert(body)
      .select()
      .single();

    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 400 });
    return new Response(JSON.stringify({ data }), { status: 201 });
  }

  if (req.method === 'PATCH') {
    const id = url.searchParams.get('id');
    if (!id) return new Response(JSON.stringify({ error: 'id is required' }), { status: 400 });

    const patch = await req.json();
    const { data, error } = await client
      .from('content_ideas')
      .update(patch)
      .eq('id', id)
      .select()
      .single();

    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 400 });
    return new Response(JSON.stringify({ data }), { status: 200 });
  }

  if (req.method === 'DELETE') {
    const id = url.searchParams.get('id');
    if (!id) return new Response(JSON.stringify({ error: 'id is required' }), { status: 400 });

    const { error } = await client.from('content_ideas').delete().eq('id', id);
    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 400 });
    return new Response(JSON.stringify({ success: true }), { status: 200 });
  }

  return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 });
});
