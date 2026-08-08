# 数据库设计（初版）

- 创建日期：2026-07-29
- 数据库：SQLite，文件位于 `backend/dental.db`
- 表结构定义：`backend/schema.sql`（唯一权威来源，改结构改这个文件）

## 表关系图

```text
users（所有人：患者/医生/管理员）
  │
  ├─ 1:1 ─→ patient_profiles.user_id      患者档案
  │
  ├─ 1:多 ─→ case_records.patient_id      患者提交的病例
  │             │
  │             ├─ 1:1 ─→ medical_summaries.case_id   病历摘要
  │             │
  │             └─ 1:多 ─→ ai_logs.case_id            大模型调用日志
  │
  └─ 1:多 ─→ medical_summaries.doctor_id   审核医生
```

## 五张表的职责

| 表名 | 职责 | 关键字段 |
| --- | --- | --- |
| `users` | 登录与身份，三种角色共用一张表 | `username` (UNIQUE)、`role` |
| `patient_profiles` | 患者的医疗背景，医生/管理员没有 | `user_id` (UNIQUE → 一对一) |
| `case_records` | 患者提交的原始病情描述，系统入口 | `patient_id`、`status` |
| `medical_summaries` | AI 摘要 + 医生审核后的版本 | `ai_summary` / `doctor_summary` |
| `ai_logs` | 每次调用大模型的输入输出，用于排查 | `prompt`、`response` |

## 关键设计决策

1. **三种角色放在同一张 `users` 表**，用 `role` 区分。避免登录逻辑写三遍。
2. **患者档案单独一张表**。医生和管理员不需要病史、出生日期这些字段。
3. **`ai_summary` 和 `doctor_summary` 分成两列**，AI 原文写入后永不修改。
   医疗系统必须可追溯"AI 说了什么、医生改了哪里"，也便于日后评估 AI 效果。
4. **`status` 字段控制流程**：
   - `case_records.status`：`submitted` → `ai_generated` → `published`
   - `medical_summaries.status`：`draft` → `published`（只有 published 患者才可见）
5. **一对一 vs 一对多**：外键加 `UNIQUE` 是一对一，不加是一对多。
6. **所有表都有 `created_at`**，默认 `CURRENT_TIMESTAMP`。

## 已知注意事项

- SQLite 默认**不检查外键**，每个连接都要执行 `PRAGMA foreign_keys = ON;`。
  第 2 周用 Python 连接数据库时，必须写进连接代码里。
- `CURRENT_TIMESTAMP` 存的是 **UTC 时间**，比北京时间早 8 小时。
  前端展示时需要转换。
- `dental.db` 不进 Git（二进制 + 含患者数据），已加入 `.gitignore`。
  重建方式：`sqlite3 dental.db < schema.sql`