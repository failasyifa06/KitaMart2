-- ============================================================================
-- KITAMART SUPABASE DATABASE SCHEMA & SEED DATA (UAS FINAL)
-- ============================================================================

-- 1. Profiles Table (Tersambung dengan auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Products Table
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    price BIGINT NOT NULL,
    image TEXT NOT NULL,
    rating NUMERIC(2,1) DEFAULT 5.0,
    description TEXT,
    category TEXT NOT NULL,
    stock INT DEFAULT 10,
    sold_count TEXT DEFAULT '100+ terjual',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Product Variants Table
CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    color TEXT,
    size TEXT,
    stock INT DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Cart Table
CREATE TABLE IF NOT EXISTS public.cart (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1,
    color TEXT,
    size TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Favorites Table
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- 6. Orders Table
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    customer_name TEXT NOT NULL,
    customer_phone TEXT,
    address TEXT NOT NULL,
    shipping_method TEXT NOT NULL, -- 'Regular' atau 'Express'
    shipping_cost BIGINT NOT NULL,
    subtotal BIGINT NOT NULL,
    total BIGINT NOT NULL,
    payment_method TEXT DEFAULT 'BCA Virtual Account',
    payment_status TEXT DEFAULT 'pending', -- 'pending', 'paid', 'expired'
    order_status TEXT DEFAULT 'Pesanan dibuat', -- 'Pesanan dibuat', 'Pembayaran berhasil', 'Diproses', 'Dikirim', 'Selesai'
    tracking_number TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Order Items Table
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    product_name TEXT NOT NULL,
    product_image TEXT,
    price BIGINT NOT NULL,
    quantity INT NOT NULL,
    color TEXT,
    size TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Reviews Table
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    variant_info TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'order',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Products & Variants: Public READ
CREATE POLICY "Products are viewable by everyone" ON public.products FOR SELECT USING (true);
CREATE POLICY "Variants are viewable by everyone" ON public.product_variants FOR SELECT USING (true);
CREATE POLICY "Reviews are viewable by everyone" ON public.reviews FOR SELECT USING (true);

-- User-specific CRUD Policies
CREATE POLICY "Users can manage own profile" ON public.profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "Users can manage own cart" ON public.cart FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own favorites" ON public.favorites FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own orders" ON public.orders FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own order items" ON public.order_items FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
);
CREATE POLICY "Users can insert reviews" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view own notifications" ON public.notifications FOR ALL USING (auth.uid() = user_id);

-- ============================================================================
-- SEED DATA 12 PRODUK WAJIB + VARIAN
-- ============================================================================

INSERT INTO public.products (id, name, price, image, rating, description, category, stock, sold_count)
VALUES
('00000000-0000-0000-0000-000000000001', 'Jam Tangan Classic Leather', 320000, 'https://images.unsplash.com/photo-1524805444758-089113d48a6d', 4.9, 'Jam tangan analog premium kulit asli bergaya formal dan santai.', 'Jam Tangan', 15, '480 terjual'),
('00000000-0000-0000-0000-000000000002', 'Dompet Kulit Bifold', 115000, 'https://images.unsplash.com/photo-1627123424574-724758594e93', 4.9, 'Dompet kulit lipat dua berkualitas dengan 8 slot kartu.', 'Dompet', 25, '630 terjual'),
('00000000-0000-0000-0000-000000000003', 'Kemeja Casual Olive', 145000, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c', 4.8, 'Kemeja santai bahan katun oxford dingin untuk keseharian.', 'Pakaian', 20, '910 terjual'),
('00000000-0000-0000-0000-000000000004', 'Crossbody Bag Tan', 185000, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa', 4.8, 'Tas selempang praktis bahan faux leather lembut buckle emas.', 'Tas', 18, '540 terjual'),
('00000000-0000-0000-0000-000000000005', 'Topi Casual Navy', 65000, 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b', 4.9, 'Topi baseball katun twill bordir minimalis strap kuningan.', 'Aksesoris', 40, '850 terjual'),
('00000000-0000-0000-0000-000000000006', 'Kaos Basic Premium', 89000, 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518', 4.8, 'Kaos polos 100% combed cotton 24s sejuk dan menyerap keringat.', 'Pakaian', 50, '1.2rb terjual'),
('00000000-0000-0000-0000-000000000007', 'Hoodie Casual Hitam', 169000, 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2', 4.9, 'Hoodie fleece katun tebal hangat dengan kantong kangguru luas.', 'Outerwear', 22, '890 terjual'),
('00000000-0000-0000-0000-000000000008', 'Gelang Minimalis Silver', 45000, 'https://images.unsplash.com/photo-1611591475152-4770e28e4695', 4.9, 'Gelang tali serut aksen plat titanium tahan karat unisex.', 'Aksesoris', 35, '310 terjual'),
('00000000-0000-0000-0000-000000000009', 'Shoulder Bag Pastel', 210000, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3', 4.7, 'Tas bahu pastel lock emas elegan untuk tampilan modern.', 'Tas', 14, '420 terjual'),
('00000000-0000-0000-0000-000000000010', 'Tote Bag Organic', 79000, 'https://images.unsplash.com/photo-1544816155-12df9643f363', 4.8, 'Tote bag kanvas organik ramah lingkungan kapasitas besar.', 'Tas', 60, '1.5rb terjual'),
('00000000-0000-0000-0000-000000000011', 'Sneakers Casual Olive', 229000, 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77', 4.8, 'Sneakers kanvas dengan insole empuk dan sol karet vulkanisir.', 'Sepatu', 19, '720 terjual'),
('00000000-0000-0000-0000-000000000012', 'Sneakers Minimalist Putih', 249000, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86', 4.9, 'Sneakers putih clean synthetic leather mudah dibersihkan.', 'Sepatu', 28, '1.1rb terjual')
ON CONFLICT (id) DO NOTHING;

-- Seed Varian Produk Sesuai Soal
-- 1. Jam Tangan: Cokelat, Hitam (tanpa ukuran)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000001', 'Cokelat', NULL, 8),
('00000000-0000-0000-0000-000000000001', 'Hitam', NULL, 7);

-- 2. Dompet: Cokelat, Hitam (tanpa ukuran)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000002', 'Cokelat', NULL, 15),
('00000000-0000-0000-0000-000000000002', 'Hitam', NULL, 10);

-- 3. Kemeja: Olive (S, M, L, XL)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000003', 'Olive', 'S', 5),
('00000000-0000-0000-0000-000000000003', 'Olive', 'M', 5),
('00000000-0000-0000-0000-000000000003', 'Olive', 'L', 5),
('00000000-0000-0000-0000-000000000003', 'Olive', 'XL', 5);

-- 4. Crossbody Bag: Tan, Hitam (tanpa ukuran)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000004', 'Tan', NULL, 10),
('00000000-0000-0000-0000-000000000004', 'Hitam', NULL, 8);

-- 5. Topi: Navy (All Size)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000005', 'Navy', 'All Size', 40);

-- 6. Kaos Basic: Putih, Hitam, Abu-abu (S, M, L, XL)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000006', 'Putih', 'S', 5),
('00000000-0000-0000-0000-000000000006', 'Putih', 'M', 5),
('00000000-0000-0000-0000-000000000006', 'Putih', 'L', 5),
('00000000-0000-0000-0000-000000000006', 'Putih', 'XL', 5),
('00000000-0000-0000-0000-000000000006', 'Hitam', 'S', 4),
('00000000-0000-0000-0000-000000000006', 'Hitam', 'M', 4),
('00000000-0000-0000-0000-000000000006', 'Hitam', 'L', 4),
('00000000-0000-0000-0000-000000000006', 'Hitam', 'XL', 4),
('00000000-0000-0000-0000-000000000006', 'Abu-abu', 'M', 5),
('00000000-0000-0000-0000-000000000006', 'Abu-abu', 'L', 5);

-- 7. Hoodie: Hitam, Abu-abu (S, M, L, XL)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000007', 'Hitam', 'M', 6),
('00000000-0000-0000-0000-000000000007', 'Hitam', 'L', 6),
('00000000-0000-0000-0000-000000000007', 'Abu-abu', 'L', 10);

-- 8. Gelang: Silver (Adjustable / All Size)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000008', 'Silver', 'Adjustable', 35);

-- 9. Shoulder Bag: Pink, Cream, Lilac (tanpa ukuran)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000009', 'Pink', NULL, 4),
('00000000-0000-0000-0000-000000000009', 'Cream', NULL, 5),
('00000000-0000-0000-0000-000000000009', 'Lilac', NULL, 5);

-- 10. Tote Bag: Natural, Hitam (tanpa ukuran)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000010', 'Natural', NULL, 35),
('00000000-0000-0000-0000-000000000010', 'Hitam', NULL, 25);

-- 11. Sneakers Casual Olive: Olive, Putih (39, 40, 41, 42, 43)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000011', 'Olive', '40', 4),
('00000000-0000-0000-0000-000000000011', 'Olive', '41', 4),
('00000000-0000-0000-0000-000000000011', 'Olive', '42', 4),
('00000000-0000-0000-0000-000000000011', 'Putih', '41', 3),
('00000000-0000-0000-0000-000000000011', 'Putih', '42', 4);

-- 12. Sneakers Minimalist Putih: Putih, Hitam (39, 40, 41, 42, 43)
INSERT INTO public.product_variants (product_id, color, size, stock) VALUES
('00000000-0000-0000-0000-000000000012', 'Putih', '39', 5),
('00000000-0000-0000-0000-000000000012', 'Putih', '40', 6),
('00000000-0000-0000-0000-000000000012', 'Putih', '41', 6),
('00000000-0000-0000-0000-000000000012', 'Putih', '42', 6),
('00000000-0000-0000-0000-000000000012', 'Hitam', '41', 5);
