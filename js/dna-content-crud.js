(function () {
  function getClient() {
    const client = window.AppSupabase?.client;
    if (!client) throw new Error('Supabase client belum siap');
    return client;
  }

  const DNA = {
    async upsertBrandDNA(payload) {
      const client = getClient();
      const { data: userData, error: userError } = await client.auth.getUser();
      if (userError || !userData?.user) throw new Error('User belum login');

      const row = {
        owner_id: userData.user.id,
        dna_mode: payload.dna_mode || 'brand',
        brand_name: payload.brand_name,
        niche: payload.niche || null,
        primary_offer: payload.primary_offer || null,
        target_audience: payload.target_audience || null,
        dna_profile: payload.dna_profile || {}
      };

      const { data, error } = await client
        .from('brands')
        .upsert(row)
        .select()
        .single();

      if (error) throw error;
      return data;
    },

    async getMyBrand() {
      const client = getClient();
      const { data: userData, error: userError } = await client.auth.getUser();
      if (userError || !userData?.user) throw new Error('User belum login');

      const { data, error } = await client
        .from('brands')
        .select('*')
        .eq('owner_id', userData.user.id)
        .eq('is_active', true)
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (error) throw error;
      return data;
    }
  };

  const Content = {
    async create(payload) {
      const client = getClient();
      const { data, error } = await client
        .from('content_ideas')
        .insert(payload)
        .select()
        .single();
      if (error) throw error;
      return data;
    },

    async listByBrand(brand_id) {
      const client = getClient();
      const { data, error } = await client
        .from('content_ideas')
        .select('*')
        .eq('brand_id', brand_id)
        .order('created_at', { ascending: false });
      if (error) throw error;
      return data;
    },

    async update(id, patch) {
      const client = getClient();
      const { data, error } = await client
        .from('content_ideas')
        .update(patch)
        .eq('id', id)
        .select()
        .single();
      if (error) throw error;
      return data;
    },

    async remove(id) {
      const client = getClient();
      const { error } = await client.from('content_ideas').delete().eq('id', id);
      if (error) throw error;
      return true;
    }
  };

  window.DNACRUD = DNA;
  window.ContentCRUD = Content;
})();
