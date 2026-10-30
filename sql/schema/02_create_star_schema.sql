/*
Project: E-commerce Sales, Customer Behaviour and Profitability Analytics
Script: 02_create_star_schema.sql
Purpose: Create dimension and fact tables for the analytical star schema.
Fact table grain: One product sales line per Row ID.
*/

USE ecommerce_analytics;

CREATE TABLE IF NOT EXISTS dim_date (
    date_key INT UNSIGNED NOT NULL,
    full_date DATE NOT NULL,
    calendar_year SMALLINT UNSIGNED NOT NULL,
    calendar_quarter CHAR(2) NOT NULL,
    month_number TINYINT UNSIGNED NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    calendar_year_month CHAR(7) NOT NULL,
    day_of_month TINYINT UNSIGNED NOT NULL,
    day_name VARCHAR(10) NOT NULL,
    week_of_year TINYINT UNSIGNED NOT NULL,
    is_weekend BOOLEAN NOT NULL,

    CONSTRAINT pk_dim_date
        PRIMARY KEY (date_key),

    CONSTRAINT uq_dim_date_full_date
        UNIQUE (full_date),

    CONSTRAINT chk_dim_date_month
        CHECK (month_number BETWEEN 1 AND 12),

    CONSTRAINT chk_dim_date_day
        CHECK (day_of_month BETWEEN 1 AND 31),

    CONSTRAINT chk_dim_date_week
        CHECK (week_of_year BETWEEN 1 AND 53)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key INT UNSIGNED NOT NULL,
    customer_name VARCHAR(120) NOT NULL,
    segment VARCHAR(30) NOT NULL,

    CONSTRAINT pk_dim_customer
        PRIMARY KEY (customer_key),

    CONSTRAINT uq_dim_customer_name
        UNIQUE (customer_name),

    CONSTRAINT chk_dim_customer_segment
        CHECK (
            segment IN (
                'Consumer',
                'Corporate',
                'Home Office'
            )
        )
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS dim_product (
    product_key INT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_id VARCHAR(40) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50) NOT NULL,

    CONSTRAINT pk_dim_product
        PRIMARY KEY (product_key),

    CONSTRAINT uq_dim_product_id
        UNIQUE (product_id),

    CONSTRAINT uq_dim_product_name
        UNIQUE (product_name),

    CONSTRAINT chk_dim_product_category
        CHECK (
            category IN (
                'Furniture',
                'Office Supplies',
                'Technology'
            )
        )
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS dim_geography (
    geography_key INT UNSIGNED NOT NULL AUTO_INCREMENT,
    geography_business_key VARCHAR(600) NOT NULL,
    postal_code VARCHAR(10) NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(120) NOT NULL,
    country VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    market VARCHAR(30) NOT NULL,
    regional_manager VARCHAR(100) NOT NULL,
    manager_mapping_status VARCHAR(30) NOT NULL,

    CONSTRAINT pk_dim_geography
        PRIMARY KEY (geography_key),

    CONSTRAINT uq_dim_geography_business_key
        UNIQUE (geography_business_key),

    CONSTRAINT chk_dim_geography_market
        CHECK (
            market IN (
                'Africa',
                'Asia Pacific',
                'Europe',
                'LATAM',
                'USCA'
            )
        ),

    CONSTRAINT chk_dim_geography_manager_status
        CHECK (
            manager_mapping_status IN (
                'Mapped',
                'Unassigned'
            )
        )
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS fact_sales (
    row_id BIGINT NOT NULL,
    order_key VARCHAR(120) NOT NULL,
    order_id VARCHAR(60) NOT NULL,
    customer_id VARCHAR(40) NOT NULL,

    order_date_key INT UNSIGNED NOT NULL,
    ship_date_key INT UNSIGNED NOT NULL,
    customer_key INT UNSIGNED NOT NULL,
    product_key INT UNSIGNED NOT NULL,
    geography_key INT UNSIGNED NOT NULL,

    ship_mode VARCHAR(30) NOT NULL,
    order_priority VARCHAR(20) NOT NULL,
    shipping_days SMALLINT UNSIGNED NOT NULL,

    quantity SMALLINT UNSIGNED NOT NULL,
    sales DECIMAL(15, 2) NOT NULL,
    sales_per_unit DECIMAL(18, 10) NOT NULL,
    discount DECIMAL(6, 4) NOT NULL,
    profit DECIMAL(15, 2) NOT NULL,
    line_profit_margin DECIMAL(18, 10) NOT NULL,
    profit_status VARCHAR(20) NOT NULL,
    shipping_cost DECIMAL(15, 3) NOT NULL,
    is_returned BOOLEAN NOT NULL,

    CONSTRAINT pk_fact_sales
        PRIMARY KEY (row_id),

    CONSTRAINT chk_fact_sales_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_fact_sales_sales
        CHECK (sales > 0),

    CONSTRAINT chk_fact_sales_discount
        CHECK (discount BETWEEN 0 AND 1),

    CONSTRAINT chk_fact_sales_shipping_cost
        CHECK (shipping_cost >= 0),

    CONSTRAINT chk_fact_sales_return
        CHECK (is_returned IN (0, 1)),

    CONSTRAINT chk_fact_sales_profit_status
        CHECK (
            profit_status IN (
                'Profit',
                'Loss',
                'Break-even'
            )
        ),

    CONSTRAINT fk_fact_sales_order_date
        FOREIGN KEY (order_date_key)
        REFERENCES dim_date (date_key),

    CONSTRAINT fk_fact_sales_ship_date
        FOREIGN KEY (ship_date_key)
        REFERENCES dim_date (date_key),

    CONSTRAINT fk_fact_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES dim_customer (customer_key),

    CONSTRAINT fk_fact_sales_product
        FOREIGN KEY (product_key)
        REFERENCES dim_product (product_key),

    CONSTRAINT fk_fact_sales_geography
        FOREIGN KEY (geography_key)
        REFERENCES dim_geography (geography_key),

    INDEX idx_fact_sales_order_key (order_key),
    INDEX idx_fact_sales_order_date (order_date_key),
    INDEX idx_fact_sales_customer (customer_key),
    INDEX idx_fact_sales_product (product_key),
    INDEX idx_fact_sales_geography (geography_key)
) ENGINE = InnoDB;