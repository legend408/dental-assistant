-- 牙科诊疗助手 数据库表结构
-- 创建日期：2026-07-29

PRAGMA foreign_keys = ON;

-- 表1：用户（患者/医生/管理员）
CREATE TABLE IF NOT EXISTS users (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role          TEXT NOT NULL CHECK (role IN ('patient', 'doctor', 'admin')),
    created_at    TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 表2：患者档案（与 users 一对一）
CREATE TABLE IF NOT EXISTS patient_profiles (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL UNIQUE,
    real_name       TEXT NOT NULL,
    gender          TEXT,
    birth_date      TEXT,
    phone           TEXT,
    medical_history TEXT,
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 表3：病例（患者提交的原始描述，与 users 一对多）
CREATE TABLE IF NOT EXISTS case_records (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id  INTEGER NOT NULL,
    description TEXT NOT NULL,
    status      TEXT NOT NULL DEFAULT 'submitted'
                CHECK (status IN ('submitted', 'ai_generated', 'published')),
    created_at  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES users(id)
);

-- 表4：病历摘要（AI 生成 + 医生审核，与 case_records 一对一）
CREATE TABLE IF NOT EXISTS medical_summaries (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    case_id        INTEGER NOT NULL UNIQUE,
    ai_summary     TEXT,
    ai_risk_notes  TEXT,
    doctor_summary TEXT,
    doctor_advice  TEXT,
    doctor_id      INTEGER,
    status         TEXT NOT NULL DEFAULT 'draft'
                   CHECK (status IN ('draft', 'published')),
    created_at     TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at   TEXT,
    FOREIGN KEY (case_id) REFERENCES case_records(id),
    FOREIGN KEY (doctor_id) REFERENCES users(id)
);

-- 表5：大模型调用日志（与 case_records 一对多）
CREATE TABLE IF NOT EXISTS ai_logs (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    case_id     INTEGER,
    model_name  TEXT,
    prompt      TEXT,
    response    TEXT,
    duration_ms INTEGER,
    status      TEXT NOT NULL DEFAULT 'success'
                CHECK (status IN ('success', 'failed')),
    created_at  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES case_records(id)
);