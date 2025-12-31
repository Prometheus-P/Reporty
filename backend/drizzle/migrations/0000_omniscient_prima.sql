CREATE TABLE "access_audit" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"report_id" uuid NOT NULL,
	"actor_id" uuid,
	"actor_role" varchar(30) NOT NULL,
	"action" varchar(30) NOT NULL,
	"reason_code" varchar(60) NOT NULL,
	"meta" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "defense_packs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"report_id" uuid NOT NULL,
	"tenant_id" uuid NOT NULL,
	"status" varchar(30) DEFAULT 'queued' NOT NULL,
	"reason_code" varchar(60) NOT NULL,
	"html_key" text NOT NULL,
	"pdf_path" text,
	"verify_ok" boolean DEFAULT false NOT NULL,
	"stored_head" varchar(64) NOT NULL,
	"computed_head" varchar(64),
	"events_count" integer DEFAULT 0 NOT NULL,
	"mismatch" jsonb,
	"snapshot_payload" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"signature" varchar(64) NOT NULL,
	"generated_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "evidence_chain" (
	"report_id" uuid PRIMARY KEY NOT NULL,
	"head_hash" varchar(64) NOT NULL,
	"algo" varchar(30) DEFAULT 'HMAC-SHA256' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "partners" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar(100) NOT NULL,
	"invite_code" varchar(20) NOT NULL,
	"api_key_hash" varchar(64) NOT NULL,
	"key_prefix" varchar(10) NOT NULL,
	"revenue_share_rate" numeric(5, 2) DEFAULT '0.00',
	"logo_url" varchar(500),
	"theme_color" varchar(7),
	"custom_header_text" varchar(200),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "partners_invite_code_unique" UNIQUE("invite_code"),
	CONSTRAINT "partners_api_key_hash_unique" UNIQUE("api_key_hash")
);
--> statement-breakpoint
CREATE TABLE "report_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"report_id" uuid NOT NULL,
	"type" varchar(60) NOT NULL,
	"actor_role" varchar(30) NOT NULL,
	"data" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"data_ciphertext" text,
	"data_key_id" varchar(120),
	"prev_event_hash" varchar(64),
	"event_hash" varchar(64) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "report_payloads" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"report_id" uuid NOT NULL,
	"ciphertext" text NOT NULL,
	"attachments" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"pii_redaction_level" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "reports" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"public_code_hash" varchar(64) NOT NULL,
	"status" varchar(30) DEFAULT 'received' NOT NULL,
	"subject" varchar(200),
	"category" varchar(60),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"last_viewed_at" timestamp with time zone,
	"encryption_key_id" varchar(120)
);
--> statement-breakpoint
CREATE TABLE "tenants" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"partner_id" uuid,
	"name" varchar(120) NOT NULL,
	"is_premium" boolean DEFAULT false NOT NULL,
	"tags" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"admin_notes" text,
	"partner_notes" text,
	"sla_policy" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"brand_config" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"email" varchar(255) NOT NULL,
	"role" varchar(30) DEFAULT 'admin' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "access_audit" ADD CONSTRAINT "access_audit_report_id_reports_id_fk" FOREIGN KEY ("report_id") REFERENCES "public"."reports"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "defense_packs" ADD CONSTRAINT "defense_packs_report_id_reports_id_fk" FOREIGN KEY ("report_id") REFERENCES "public"."reports"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "defense_packs" ADD CONSTRAINT "defense_packs_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "evidence_chain" ADD CONSTRAINT "evidence_chain_report_id_reports_id_fk" FOREIGN KEY ("report_id") REFERENCES "public"."reports"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "report_events" ADD CONSTRAINT "report_events_report_id_reports_id_fk" FOREIGN KEY ("report_id") REFERENCES "public"."reports"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "report_payloads" ADD CONSTRAINT "report_payloads_report_id_reports_id_fk" FOREIGN KEY ("report_id") REFERENCES "public"."reports"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "reports" ADD CONSTRAINT "reports_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "tenants" ADD CONSTRAINT "tenants_partner_id_partners_id_fk" FOREIGN KEY ("partner_id") REFERENCES "public"."partners"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "access_audit_report_created_idx" ON "access_audit" USING btree ("report_id","created_at");--> statement-breakpoint
CREATE INDEX "defense_packs_report_created_idx" ON "defense_packs" USING btree ("report_id","created_at");--> statement-breakpoint
CREATE INDEX "defense_packs_tenant_created_idx" ON "defense_packs" USING btree ("tenant_id","created_at");--> statement-breakpoint
CREATE INDEX "report_events_report_created_idx" ON "report_events" USING btree ("report_id","created_at");--> statement-breakpoint
CREATE UNIQUE INDEX "report_payloads_report_uniq" ON "report_payloads" USING btree ("report_id");--> statement-breakpoint
CREATE INDEX "reports_tenant_status_idx" ON "reports" USING btree ("tenant_id","status");--> statement-breakpoint
CREATE UNIQUE INDEX "reports_public_code_hash_uniq" ON "reports" USING btree ("public_code_hash");--> statement-breakpoint
CREATE INDEX "tenants_partner_idx" ON "tenants" USING btree ("partner_id");--> statement-breakpoint
CREATE UNIQUE INDEX "users_tenant_email_uniq" ON "users" USING btree ("tenant_id","email");