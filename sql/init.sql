-- =====================================================
-- 农作物种植生产管理系统 - 数据库初始化脚本
-- Database: crop_management
-- =====================================================

CREATE DATABASE IF NOT EXISTS crop_management DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE crop_management;

SET NAMES utf8mb4;
SET CHARACTER_SET_CLIENT = utf8mb4;
SET CHARACTER_SET_RESULTS = utf8mb4;
SET CHARACTER_SET_CONNECTION = utf8mb4;

-- =====================================================
-- 1. 用户表 (sys_user)
-- =====================================================
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码(BCrypt加密)',
    real_name VARCHAR(50) COMMENT '真实姓名',
    phone VARCHAR(20) COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    avatar VARCHAR(255) COMMENT '头像URL',
    role TINYINT NOT NULL DEFAULT 0 COMMENT '角色: 0-种植户, 1-管理员, 2-技术员',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用, 1-正常',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_username (username),
    KEY idx_role (role),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户表';

-- =====================================================
-- 2. 作物信息表 (crop)
-- =====================================================
DROP TABLE IF EXISTS crop;
CREATE TABLE crop (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    name VARCHAR(100) NOT NULL COMMENT '作物名称',
    variety VARCHAR(100) COMMENT '品种',
    growth_cycle INT COMMENT '生长周期(天)',
    planting_season VARCHAR(50) COMMENT '种植季节',
    suitable_region VARCHAR(200) COMMENT '适宜区域',
    description TEXT COMMENT '描述',
    image VARCHAR(255) COMMENT '图片URL',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='作物信息表';

-- =====================================================
-- 3. 地块表 (plot)
-- =====================================================
DROP TABLE IF EXISTS plot;
CREATE TABLE plot (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '所属种植户ID',
    name VARCHAR(100) NOT NULL COMMENT '地块名称',
    area DECIMAL(10,2) COMMENT '面积(亩)',
    location VARCHAR(200) COMMENT '位置',
    soil_type VARCHAR(50) COMMENT '土壤类型',
    description TEXT COMMENT '描述',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='地块表';

-- =====================================================
-- 4. 种植计划表 (planting_plan)
-- =====================================================
DROP TABLE IF EXISTS planting_plan;
CREATE TABLE planting_plan (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '种植户ID',
    crop_id BIGINT NOT NULL COMMENT '作物ID',
    plot_id BIGINT COMMENT '地块ID',
    plan_name VARCHAR(200) NOT NULL COMMENT '计划名称',
    planned_area DECIMAL(10,2) COMMENT '计划面积(亩)',
    planned_start_date DATE COMMENT '计划开始日期',
    planned_end_date DATE COMMENT '计划结束日期',
    actual_start_date DATE COMMENT '实际开始日期',
    actual_end_date DATE COMMENT '实际结束日期',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态: 0-待审核, 1-已通过, 2-已拒绝, 3-进行中, 4-已完成',
    description TEXT COMMENT '计划描述',
    review_note TEXT COMMENT '审核备注',
    reviewer_id BIGINT COMMENT '审核人ID',
    review_time DATETIME COMMENT '审核时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_user_id (user_id),
    KEY idx_crop_id (crop_id),
    KEY idx_status (status),
    KEY idx_plot_id (plot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='种植计划表';

-- =====================================================
-- 5. 田间作业记录表 (field_operation)
-- =====================================================
DROP TABLE IF EXISTS field_operation;
CREATE TABLE field_operation (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    plan_id BIGINT NOT NULL COMMENT '种植计划ID',
    user_id BIGINT NOT NULL COMMENT '操作人ID',
    operation_type TINYINT NOT NULL COMMENT '作业类型: 1-灌溉, 2-施肥, 3-打药, 4-除草, 5-收获, 6-其他',
    operation_date DATE NOT NULL COMMENT '作业日期',
    description TEXT COMMENT '作业描述',
    images VARCHAR(1000) COMMENT '图片URLs(JSON数组)',
    material_id BIGINT COMMENT '使用的农资ID',
    material_quantity DECIMAL(10,2) COMMENT '使用农资数量',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_plan_id (plan_id),
    KEY idx_user_id (user_id),
    KEY idx_operation_type (operation_type),
    KEY idx_operation_date (operation_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='田间作业记录表';

-- =====================================================
-- 6. 农资信息表 (agricultural_material)
-- =====================================================
DROP TABLE IF EXISTS agricultural_material;
CREATE TABLE agricultural_material (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    name VARCHAR(200) NOT NULL COMMENT '农资名称',
    type TINYINT NOT NULL COMMENT '类型: 1-种子, 2-化肥, 3-农药, 4-工具, 5-其他',
    unit VARCHAR(20) COMMENT '单位',
    specification VARCHAR(200) COMMENT '规格',
    manufacturer VARCHAR(200) COMMENT '生产厂家',
    price DECIMAL(10,2) COMMENT '单价(元)',
    description TEXT COMMENT '描述',
    image VARCHAR(255) COMMENT '图片URL',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_name (name),
    KEY idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='农资信息表';

-- =====================================================
-- 7. 库存表 (inventory)
-- =====================================================
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    material_id BIGINT NOT NULL COMMENT '农资ID',
    quantity DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '当前库存数量',
    warning_threshold DECIMAL(10,2) DEFAULT 0 COMMENT '预警阈值',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_material_id (material_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='库存表';

-- =====================================================
-- 8. 库存变动记录表 (inventory_record)
-- =====================================================
DROP TABLE IF EXISTS inventory_record;
CREATE TABLE inventory_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    material_id BIGINT NOT NULL COMMENT '农资ID',
    user_id BIGINT NOT NULL COMMENT '操作人ID',
    type TINYINT NOT NULL COMMENT '类型: 1-入库(采购), 2-出库(领用)',
    quantity DECIMAL(10,2) NOT NULL COMMENT '数量',
    reason VARCHAR(500) COMMENT '原因/备注',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    KEY idx_material_id (material_id),
    KEY idx_user_id (user_id),
    KEY idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='库存变动记录表';

-- =====================================================
-- 9. 产量记录表 (yield_record)
-- =====================================================
DROP TABLE IF EXISTS yield_record;
CREATE TABLE yield_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    plan_id BIGINT NOT NULL COMMENT '种植计划ID',
    user_id BIGINT NOT NULL COMMENT '记录人ID',
    quantity DECIMAL(10,2) NOT NULL COMMENT '产量',
    unit VARCHAR(20) DEFAULT '斤' COMMENT '单位',
    harvest_date DATE NOT NULL COMMENT '收获日期',
    quality VARCHAR(50) COMMENT '品质等级',
    notes TEXT COMMENT '备注',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_plan_id (plan_id),
    KEY idx_user_id (user_id),
    KEY idx_harvest_date (harvest_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='产量记录表';

-- =====================================================
-- 10. 成本记录表 (cost_record)
-- =====================================================
DROP TABLE IF EXISTS cost_record;
CREATE TABLE cost_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    plan_id BIGINT NOT NULL COMMENT '种植计划ID',
    user_id BIGINT NOT NULL COMMENT '记录人ID',
    type TINYINT NOT NULL COMMENT '类型: 1-种子, 2-化肥, 3-农药, 4-人工, 5-设备, 6-其他',
    amount DECIMAL(10,2) NOT NULL COMMENT '金额(元)',
    description VARCHAR(500) COMMENT '描述',
    cost_date DATE NOT NULL COMMENT '成本发生日期',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_plan_id (plan_id),
    KEY idx_user_id (user_id),
    KEY idx_type (type),
    KEY idx_cost_date (cost_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='成本记录表';

-- =====================================================
-- 11. 公告表 (announcement)
-- =====================================================
DROP TABLE IF EXISTS announcement;
CREATE TABLE announcement (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    title VARCHAR(200) NOT NULL COMMENT '标题',
    content TEXT NOT NULL COMMENT '内容',
    publisher_id BIGINT NOT NULL COMMENT '发布人ID',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态: 0-草稿, 1-已发布',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_publisher_id (publisher_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='公告表';

-- =====================================================
-- 12. 技术指导表 (technical_guidance)
-- =====================================================
DROP TABLE IF EXISTS technical_guidance;
CREATE TABLE technical_guidance (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    title VARCHAR(200) NOT NULL COMMENT '标题',
    content TEXT NOT NULL COMMENT '内容',
    crop_id BIGINT COMMENT '关联作物ID',
    author_id BIGINT NOT NULL COMMENT '作者ID',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_crop_id (crop_id),
    KEY idx_author_id (author_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='技术指导表';

-- =====================================================
-- 13. 系统日志表 (system_log)
-- =====================================================
DROP TABLE IF EXISTS system_log;
CREATE TABLE system_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT COMMENT '操作用户ID',
    username VARCHAR(50) COMMENT '用户名',
    module VARCHAR(100) COMMENT '模块',
    action VARCHAR(200) COMMENT '操作',
    description TEXT COMMENT '描述',
    ip VARCHAR(50) COMMENT 'IP地址',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    KEY idx_user_id (user_id),
    KEY idx_module (module),
    KEY idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统日志表';

-- =====================================================
-- 14. 系统配置表 (system_config)
-- =====================================================
DROP TABLE IF EXISTS system_config;
CREATE TABLE system_config (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    config_key VARCHAR(100) NOT NULL COMMENT '配置键',
    config_value VARCHAR(500) COMMENT '配置值',
    description VARCHAR(200) COMMENT '描述',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_config_key (config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统配置表';
