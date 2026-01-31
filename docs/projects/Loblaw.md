---
title: Mastering the Data Journey - Building Robust Pipelines for Marketing Mixed Modeling (MMM)
description: A Data Engineering Portfolio Project leveraging Medallion Architecture, Google BigQuery, and Data Governance tools.
slug: data-engineering-mmm-pipeline
authors:
  - your_name
date: 2025-10-28
tags:
  - Data Engineering
  - BigQuery
  - ETL
  - Medallion Architecture
  - Data Quality
  - GCP
---

# Mastering the Data Journey: Building Robust ETL Pipelines for Marketing Mixed Modeling (MMM)

My Co-op was spent working full-time as a Data Analyst on the Data Engineering team at Loblaw Headquarters in Brampton Ontario. This document details my work on the **Elevated Data Foundations (EDF)** project, a core initiative to build a scalable, high-quality data pipeline on Google Cloud Platform (GCP). The project’s objective was to aggregate, cleanse, and model diverse marketing data to create the input dataset for a **Marketing Mixed Model (MMM)**, enabling precise calculation of marketing ROI.

## 1. Project Scope & Architecture: The EDF & The Medallion Model

The **EDF project** established the data infrastructure within our dedicated GCP project, utilizing **BigQuery** as the primary Data Warehouse/Lakehouse layer. The data architecture follows a multi-stage **Medallion Architecture**, adapted to our internal organizational zones: **RAW, TechData, Consume, and Fulfillment.**

The entire environment, including our BigQuery datasets and managed resources, was provisioned and governed under our internal DBaaS platform, **'Cerebro'**.

### Layered Data Zones

| Zone Name | Medallion Layer | Data State | Primary Function |
| :--- | :--- | :--- | :--- |
| **RAW** | **Bronze / Landing** | Immutable, **Untouched**. | Data Ingestion. Historical Archive. |
| **TechData** | **Silver** | **Cleaned, Standardized**. | Initial Remediation, Data Quality Checks, Tokenization. |
| **Consume** | **Silver / Gold** | **Conformed, Modeled**. | Implementing Business Logic, Dimensional Modeling, Analytics-ready tables. |
| **Fulfillment** | **Gold** | **Aggregated, Optimized**. | Final delivery to consuming applications (e.g., MMM, BI Dashboards). |

### Environments

ETL development and deployment were strictly separated across environments:

* **EXP (Exploration/Dev):** Development and initial unit testing (e.g., `Lt-dia-exp-raw`).
* **VAL (Validation):** Integration testing and rigorous data quality validation (e.g., `Lt-dia-lake-val-consume`).
* **PROD (Production):** Automated, scheduled pipelines serving live data (e.g., `Lt-dia-lake-prd-fulfillment`).

---

## 2. Ingestion and the RAW Zone (Bronze)

The process begins with the **Data Ingestion** into the **RAW** zone, ensuring an auditable, unmutated copy of the source data.

* **Sources:** Data streams from various internal systems, often delivered as flat files or extracted from legacy systems like **Teradata**.
* **Methodology:** For high-volume tables, we prioritized **Change Data Capture (CDC)** to track daily evolutions efficiently, using `Initial` loads for setup and subsequent `Delta` loads to capture only the net changes.
* **Data Preservation:** Data lands in BigQuery tables or Cloud Storage, stored exactly in its native format. My role required **Source Analysis** to understand the schema and data characteristics *before* any transformation.

---

## 3. Transformation and Data Quality (TechData & Consume)

The bulk of the **Extract, Transform, Load (ETL)** effort occurs as data moves from RAW through the **TechData** and **Consume** layers.

### BigQuery as the Transformation Engine

We leveraged **BigQuery's robust SQL** capabilities to perform all transformations, using it as our primary ELT (Extract-Load-Transform) tool.

| ETL Step | Description | Technical Focus (BigQuery) |
| :--- | :--- | :--- |
| **Cleansing** | Removing duplicates, handling `NULL` values, correcting data types, and enforcing non-nullable constraints. | `DISTINCT`, `CAST`, `COALESCE`, and `NOT NULL` constraints in table DDL. |
| **Standardization** | Ensuring consistent formats (e.g., `YYYY-MM-DD` for all dates, standardized currency codes). | Date/time functions (`PARSE_DATE`), conditional logic (`CASE` statements). |
| **Modeling** | Joining data from disparate raw tables to create unified dimensional and fact structures, adhering to Kimball principles. | Complex `JOIN` operations, Window Functions for derived metrics. |
| **Business Logic** | Implementing specific rules (e.g., calculated metrics, custom campaign classification). | UDFs (User-Defined Functions), complex `CASE` statements to apply business rules. |

### Data Quality (DQ) & Remediation

* **Tools Integration:** We integrated **Attaccama**, a specialized Data Quality and Governance platform, to apply complex DQ rules, perform **Data Profiling**, and manage **Data Remediation** processes.
* **Validation:** Before promoting data, we executed rigorous checks:
    * **Volume and Freshness Checks:** Asserting that expected row counts were delivered and processed within SLAs.
    * **Cross-Source Integrity:** Comparing our processed metrics against curated data provided by external partners like **Deloitte** to ensure accuracy and alignment.
    * **Exception Reports:** Generating reports to highlight significant data quality deviations for stakeholder review.

### Security and Governance

* **Tokenization:** Sensitive data fields (e.g., PII derived from AA/GA feeds) were immediately **TOKENIZED** in the **TechData** layer to maintain compliance and privacy, ensuring raw PII never progressed downstream.
* **Data Classification:** Collaborating with the Enterprise Integration team to apply rules for **classifying domains and sub-domains**, ensuring consistent governance and access control across the pipeline.

---

## 4. The Marketing Taxonomy Tool (MTT) & Fulfillment

The ultimate goal of the pipeline was to feed the analytics and predictive modeling efforts, centralized around the **Marketing Taxonomy Tool (MTT)**.

### The MTT Project

1.  **STEP ONE: Create Taxonomy Tool**
    * A Central Marketing Taxonomy Tool was established to serve as the **standardized method for tracking all products across different promotions**. This single source of truth resolves inconsistencies in campaign and product naming.
    * The tool directly governs **UTM Tagging** (e.g., `www.example.com?utm_campaign=...`), ensuring that all digital campaign links use standardized codes that map perfectly to the MTT's dimensions.

2.  **STEP TWO: Centralize Data into EDF Pipelines**
    * The ETL work detailed above ensures the data is cleansed, mapped, and ready to be joined with the MTT lookup tables in the **Consume** layer. This is how marketing can now consistently track **'each data spend' for every campaign.**

3.  **STEP THREE: Final Delivery and Automation**
    * Data is aggregated in the **Fulfillment** layer, optimized for high-performance retrieval.
    * This final dataset is provided to **Neustar** for the **Marketing Mixed Modeling (MMM)**, aimed at creating a robust predictive model.
    * The end goal is a fully **automated process by Q4**, minimizing manual oversight. Concurrently, the dashboard-building team will gain access to the campaign data, enabling them to visualize performance metrics derived from the MTT-conformed data.

---

## Conclusion: Engineering for Insight

This project demonstrated expertise in designing and maintaining multi-stage data pipelines on GCP. From defining granular transformation logic in **BigQuery** and integrating advanced DQ tools like **Attaccama**, to successfully structuring data according to the **Medallion Architecture**, the **EDF** project provides a reliable, governed foundation for advanced analytics. The pipeline successfully transforms chaotic raw