--Tabel Analisis Project Based Internship Kimia Farma
--Alifah Khairina

#Membuat tabel baru bernama `tabel_analisa` di dataset kimia_farma
CREATE TABLE `rakamin-kf-analytics.kimia_farma.tabel_analisa` AS

# Membuat CTE untuk menyusun data awal sebelum digabungkan
WITH transaksi AS (    
  # Mengambil data transaksi dari tabel kf_final_transaction       
  SELECT 
    transaction_id,
    date,
    branch_id,
    product_id,
    price as actual_price,
    discount_percentage,
    customer_name,
    rating as rating_transaksi,
    # Menghitung nett_sales (harga setelah diskon)
    price*(1-discount_percentage) AS nett_sales,

    # Menentukan persentasi gross laba berdasarkan kategori harga produk
    case 
          when price <= 50000 then 10
          when price > 50000 and price <= 100000 then 15
          when price > 100000 and price <= 300000 then 20
          when price > 300000 and price <= 500000 then 25
          when price > 500000 then 30
        end as persentase_gross_laba
  FROM `kimia_farma.kf_final_transaction`

),

produk AS (
  # Mengambil data produk dari tabel kf_product
  SELECT
    product_id,
    product_name,
    product_category,
  FROM `kimia_farma.kf_product`
),

cabang AS (
  # Mengambil data cabang dari tabel kf_kantor_cabang
  SELECT 
    branch_id,
    branch_name,
    kota,
    provinsi,
    rating as rating_cabang
  FROM `kimia_farma.kf_kantor_cabang`
),

inventory AS (
  # Mengambil data inventory dari tabel kf_inventory
  SELECT 
    product_id,
    branch_id,  
    opname_stock as stock
  FROM `kimia_farma.kf_inventory`
)


  --TABEL ANALISA
# Menggabungkan semua CTE 
SELECT 
  transaksi.transaction_id,
  transaksi.date,
  transaksi.customer_name,
  transaksi.actual_price,
  transaksi.discount_percentage,
  transaksi.persentase_gross_laba,
  transaksi.nett_sales,
  transaksi.rating_transaksi,
  transaksi.nett_sales*(persentase_gross_laba/100) as nett_profit,
  transaksi.product_id,
  cabang.branch_id,
  cabang.branch_name,
  cabang.kota,
  cabang.provinsi,
  cabang.rating_cabang,
  produk.product_name,
  produk.product_category,
  inventory.stock
FROM transaksi 
JOIN produk 
  ON transaksi.product_id = produk.product_id
JOIN cabang 
  ON transaksi.branch_id = cabang.branch_id
LEFT JOIN inventory 
  ON transaksi.product_id = inventory.product_id
  AND transaksi.branch_id = inventory.branch_id

# Mengurutkan data berdasarkan tanggal transaksi
ORDER BY transaksi.date
