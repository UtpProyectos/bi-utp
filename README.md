# 📘 README – Organización de Scripts SQL

## 🗂️ Carpetas
```
sql/
├─ ddl/         → Tablas y esquemas (estructura)
├─ seeds/       → Datos iniciales (catálogos)
├─ procedures/  → Procedimientos almacenados
└─ dml/         → Cargas y ejecuciones
```

## 🔢 Orden y nombres
Usa números al inicio para mantener el orden:
```
001_crear_esquemas.sql
002_tabla_dim_cliente.sql
003_tabla_fact_ventas.sql
```

## ⚙️ Procedimientos almacenados
Guárdalos en `/procedures` con nombres claros:
```
sp_etl_cargar_dim_cliente.sql
sp_rpt_ventas_mensuales.sql
```

## 🚀 Ejecución recomendada
1️⃣ Ejecutar scripts de `ddl`  
2️⃣ Ejecutar `seeds`  
3️⃣ Crear `procedures`  
4️⃣ Correr los de `dml` (pueden llamar a los SP)

📄 **Ejemplo:**
```sql
EXEC dwh.sp_etl_cargar_dim_cliente;
EXEC dwh.sp_etl_cargar_fact_ventas;
```
