/*
Project: E-commerce Sales, Customer Behaviour and Profitability Analytics
Script: 01_create_database_and_tables.sql
Purpose: Create the MySQL analytics database and cleaned-order staging table.
Staging grain: One product sales line per Row ID.
*/

CREATE DATABASE IF NOT EXISTS ecommerce_analytics
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE ecommerce_analytics;

CREATE TABLE IF NOT EXISTS stg_orders (
    row_id BIGINT NOT NULL,
    order_key VARCHAR(120) NOT NULL,
    order_id VARCHAR(60) NOT NULL,

    order_date DATE NOT NULL,
    ship_date DATE NOT NULL,
    shipping_days SMALLINT UNSIGNED NOT NULL,
    order_year SMALLINT UNSIGNED NOT NULL,
    order_quarter CHAR(2) NOT NULL,
    order_month TINYINT UNSIGNED NOT NULL,
    order_month_name VARCHAR(10) NOT NULL,
    order_year_month CHAR(7) NOT NULL,

    ship_mode VARCHAR(30) NOT NULL,
    order_priority VARCHAR(20) NOT NULL,

    customer_key INT UNSIGNED NOT NULL,
    customer_id VARCHAR(40) NOT NULL,
    customer_name VARCHAR(120) NOT NULL,
    segment VARCHAR(30) NOT NULL,

    postal_code VARCHAR(10) NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(120) NOT NULL,
    country VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    market VARCHAR(30) NOT NULL,
    regional_manager VARCHAR(100) NOT NULL,
    manager_mapping_status VARCHAR(30) NOT NULL,

    product_id VARCHAR(40) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50) NOT NULL,

    quantity SMALLINT UNSIGNED NOT NULL,
    sales DECIMAL(15, 2) NOT NULL,
    sales_per_unit DECIMAL(18, 10) NOT NULL,
    discount DECIMAL(6, 4) NOT NULL,
    profit DECIMAL(15, 2) NOT NULL,
    line_profit_margin DECIMAL(18, 10) NOT NULL,
    profit_status VARCHAR(20) NOT NULL,
    shipping_cost DECIMAL(15, 3) NOT NULL,
    is_returned VARCHAR(5) NOT NULL,

    CONSTRAINT pk_stg_orders
        PRIMARY KEY (row_id),

    INDEX idx_stg_orders_order_key (order_key),
    INDEX idx_stg_orders_customer_key (customer_key),
    INDEX idx_stg_orders_product_id (product_id)
) ENGINE = InnoDB;

SELECT DATABASE() AS active_database;