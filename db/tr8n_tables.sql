-- Table: tr8n_glossary

-- DROP TABLE tr8n_glossary;

CREATE TABLE tr8n_glossary
(
  id serial NOT NULL,
  keyword character varying(255),
  description text,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_glossary_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_glossary OWNER TO postgres;

-- Index: index_tr8n_glossary_on_keyword

-- DROP INDEX index_tr8n_glossary_on_keyword;

CREATE INDEX index_tr8n_glossary_on_keyword
  ON tr8n_glossary
  USING btree
  (keyword);

-- Table: tr8n_language_forum_abuse_reports

-- DROP TABLE tr8n_language_forum_abuse_reports;

CREATE TABLE tr8n_language_forum_abuse_reports
(
  id serial NOT NULL,
  language_id integer NOT NULL,
  translator_id integer NOT NULL,
  language_forum_message_id integer NOT NULL,
  reason character varying(255),
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_language_forum_abuse_reports_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_language_forum_abuse_reports OWNER TO postgres;

-- Index: index_tr8n_language_forum_abuse_reports_on_language_forum_messa

-- DROP INDEX index_tr8n_language_forum_abuse_reports_on_language_forum_messa;

CREATE INDEX index_tr8n_language_forum_abuse_reports_on_language_forum_messa
  ON tr8n_language_forum_abuse_reports
  USING btree
  (language_forum_message_id);

-- Index: index_tr8n_language_forum_abuse_reports_on_language_id

-- DROP INDEX index_tr8n_language_forum_abuse_reports_on_language_id;

CREATE INDEX index_tr8n_language_forum_abuse_reports_on_language_id
  ON tr8n_language_forum_abuse_reports
  USING btree
  (language_id);

-- Index: index_tr8n_language_forum_abuse_reports_on_language_id_and_tran

-- DROP INDEX index_tr8n_language_forum_abuse_reports_on_language_id_and_tran;

CREATE INDEX index_tr8n_language_forum_abuse_reports_on_language_id_and_tran
  ON tr8n_language_forum_abuse_reports
  USING btree
  (language_id, translator_id);

-- Table: tr8n_language_forum_messages

-- DROP TABLE tr8n_language_forum_messages;

CREATE TABLE tr8n_language_forum_messages
(
  id serial NOT NULL,
  language_id integer NOT NULL,
  language_forum_topic_id integer NOT NULL,
  translator_id integer NOT NULL,
  message text NOT NULL,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_language_forum_messages_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_language_forum_messages OWNER TO postgres;

-- Index: index_tr8n_language_forum_messages_on_language_id

-- DROP INDEX index_tr8n_language_forum_messages_on_language_id;

CREATE INDEX index_tr8n_language_forum_messages_on_language_id
  ON tr8n_language_forum_messages
  USING btree
  (language_id);

-- Index: index_tr8n_language_forum_messages_on_language_id_and_language_

-- DROP INDEX index_tr8n_language_forum_messages_on_language_id_and_language_;

CREATE INDEX index_tr8n_language_forum_messages_on_language_id_and_language_
  ON tr8n_language_forum_messages
  USING btree
  (language_id, language_forum_topic_id);

-- Index: index_tr8n_language_forum_messages_on_translator_id

-- DROP INDEX index_tr8n_language_forum_messages_on_translator_id;

CREATE INDEX index_tr8n_language_forum_messages_on_translator_id
  ON tr8n_language_forum_messages
  USING btree
  (translator_id);

-- Table: tr8n_language_forum_topics

-- DROP TABLE tr8n_language_forum_topics;

CREATE TABLE tr8n_language_forum_topics
(
  id serial NOT NULL,
  translator_id integer NOT NULL,
  language_id integer,
  topic text NOT NULL,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_language_forum_topics_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_language_forum_topics OWNER TO postgres;

-- Index: index_tr8n_language_forum_topics_on_language_id

-- DROP INDEX index_tr8n_language_forum_topics_on_language_id;

CREATE INDEX index_tr8n_language_forum_topics_on_language_id
  ON tr8n_language_forum_topics
  USING btree
  (language_id);

-- Index: index_tr8n_language_forum_topics_on_translator_id

-- DROP INDEX index_tr8n_language_forum_topics_on_translator_id;

CREATE INDEX index_tr8n_language_forum_topics_on_translator_id
  ON tr8n_language_forum_topics
  USING btree
  (translator_id);

-- Table: tr8n_language_metrics

-- DROP TABLE tr8n_language_metrics;

CREATE TABLE tr8n_language_metrics
(
  id serial NOT NULL,
  "type" character varying(255),
  language_id integer NOT NULL,
  metric_date date NOT NULL,
  user_count integer DEFAULT 0,
  translator_count integer DEFAULT 0,
  translation_count integer DEFAULT 0,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_language_metrics_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_language_metrics OWNER TO postgres;

-- Index: index_tr8n_language_metrics_on_language_id

-- DROP INDEX index_tr8n_language_metrics_on_language_id;

CREATE INDEX index_tr8n_language_metrics_on_language_id
  ON tr8n_language_metrics
  USING btree
  (language_id);

-- Table: tr8n_language_rules

-- DROP TABLE tr8n_language_rules;

CREATE TABLE tr8n_language_rules
(
  id serial NOT NULL,
  language_id integer NOT NULL,
  translator_id integer,
  "type" character varying(255),
  multipart boolean,
  part1 character varying(255),
  value1 character varying(255),
  "operator" character varying(255),
  part2 character varying(255),
  value2 character varying(255),
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_language_rules_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_language_rules OWNER TO postgres;

-- Index: index_tr8n_language_rules_on_language_id

-- DROP INDEX index_tr8n_language_rules_on_language_id;

CREATE INDEX index_tr8n_language_rules_on_language_id
  ON tr8n_language_rules
  USING btree
  (language_id);

-- Index: index_tr8n_language_rules_on_language_id_and_translator_id

-- DROP INDEX index_tr8n_language_rules_on_language_id_and_translator_id;

CREATE INDEX index_tr8n_language_rules_on_language_id_and_translator_id
  ON tr8n_language_rules
  USING btree
  (language_id, translator_id);

-- Table: tr8n_language_users

-- DROP TABLE tr8n_language_users;

CREATE TABLE tr8n_language_users
(
  id serial NOT NULL,
  language_id integer NOT NULL,
  user_id integer NOT NULL,
  translator_id integer,
  manager boolean DEFAULT false,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_language_users_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_language_users OWNER TO postgres;

-- Index: index_tr8n_language_users_on_language_id_and_translator_id

-- DROP INDEX index_tr8n_language_users_on_language_id_and_translator_id;

CREATE INDEX index_tr8n_language_users_on_language_id_and_translator_id
  ON tr8n_language_users
  USING btree
  (language_id, translator_id);

-- Index: index_tr8n_language_users_on_language_id_and_user_id

-- DROP INDEX index_tr8n_language_users_on_language_id_and_user_id;

CREATE INDEX index_tr8n_language_users_on_language_id_and_user_id
  ON tr8n_language_users
  USING btree
  (language_id, user_id);

-- Index: index_tr8n_language_users_on_user_id

-- DROP INDEX index_tr8n_language_users_on_user_id;

CREATE INDEX index_tr8n_language_users_on_user_id
  ON tr8n_language_users
  USING btree
  (user_id);

-- Table: tr8n_languages

-- DROP TABLE tr8n_languages;

CREATE TABLE tr8n_languages
(
  id serial NOT NULL,
  locale character varying(255) NOT NULL,
  english_name character varying(255) NOT NULL,
  native_name character varying(255),
  enabled boolean,
  right_to_left boolean,
  completeness integer,
  fallback_language_id integer,
  curse_words text,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_languages_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_languages OWNER TO postgres;

-- Index: index_tr8n_languages_on_locale

-- DROP INDEX index_tr8n_languages_on_locale;

CREATE INDEX index_tr8n_languages_on_locale
  ON tr8n_languages
  USING btree
  (locale);

-- Table: tr8n_translation_key_locks

-- DROP TABLE tr8n_translation_key_locks;

CREATE TABLE tr8n_translation_key_locks
(
  id serial NOT NULL,
  translation_key_id integer NOT NULL,
  language_id integer NOT NULL,
  translator_id integer NOT NULL,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_translation_key_locks_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_translation_key_locks OWNER TO postgres;

-- Index: index_tr8n_translation_key_locks_on_translation_key_id_and_lang

-- DROP INDEX index_tr8n_translation_key_locks_on_translation_key_id_and_lang;

CREATE INDEX index_tr8n_translation_key_locks_on_translation_key_id_and_lang
  ON tr8n_translation_key_locks
  USING btree
  (translation_key_id, language_id);

-- Table: tr8n_translation_key_sources

-- DROP TABLE tr8n_translation_key_sources;

CREATE TABLE tr8n_translation_key_sources
(
  id serial NOT NULL,
  translation_key_id integer NOT NULL,
  translation_source_id integer NOT NULL,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_translation_key_sources_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_translation_key_sources OWNER TO postgres;

-- Index: index_tr8n_translation_key_sources_on_translation_key_id

-- DROP INDEX index_tr8n_translation_key_sources_on_translation_key_id;

CREATE INDEX index_tr8n_translation_key_sources_on_translation_key_id
  ON tr8n_translation_key_sources
  USING btree
  (translation_key_id);

-- Index: index_tr8n_translation_key_sources_on_translation_source_id

-- DROP INDEX index_tr8n_translation_key_sources_on_translation_source_id;

CREATE INDEX index_tr8n_translation_key_sources_on_translation_source_id
  ON tr8n_translation_key_sources
  USING btree
  (translation_source_id);

-- Table: tr8n_translation_keys

-- DROP TABLE tr8n_translation_keys;

CREATE TABLE tr8n_translation_keys
(
  id serial NOT NULL,
  "key" character varying(255) NOT NULL,
  label text NOT NULL,
  description text,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_translation_keys_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_translation_keys OWNER TO postgres;

-- Index: index_tr8n_translation_keys_on_key

-- DROP INDEX index_tr8n_translation_keys_on_key;

CREATE INDEX index_tr8n_translation_keys_on_key
  ON tr8n_translation_keys
  USING btree
  (key);

-- Table: tr8n_translation_rules

-- DROP TABLE tr8n_translation_rules;

CREATE TABLE tr8n_translation_rules
(
  id serial NOT NULL,
  translation_id integer NOT NULL,
  language_rule_id integer NOT NULL,
  token character varying(255),
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_translation_rules_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_translation_rules OWNER TO postgres;

-- Index: index_tr8n_translation_rules_on_translation_id

-- DROP INDEX index_tr8n_translation_rules_on_translation_id;

CREATE INDEX index_tr8n_translation_rules_on_translation_id
  ON tr8n_translation_rules
  USING btree
  (translation_id);

-- Table: tr8n_translation_sources

-- DROP TABLE tr8n_translation_sources;

CREATE TABLE tr8n_translation_sources
(
  id serial NOT NULL,
  source character varying(255),
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_translation_sources_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_translation_sources OWNER TO postgres;

-- Index: index_tr8n_translation_sources_on_source

-- DROP INDEX index_tr8n_translation_sources_on_source;

CREATE INDEX index_tr8n_translation_sources_on_source
  ON tr8n_translation_sources
  USING btree
  (source);

-- Table: tr8n_translation_votes

-- DROP TABLE tr8n_translation_votes;

CREATE TABLE tr8n_translation_votes
(
  id serial NOT NULL,
  translation_id integer NOT NULL,
  translator_id integer NOT NULL,
  vote integer NOT NULL,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_translation_votes_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_translation_votes OWNER TO postgres;

-- Index: index_tr8n_translation_votes_on_translation_id_and_translator_i

-- DROP INDEX index_tr8n_translation_votes_on_translation_id_and_translator_i;

CREATE INDEX index_tr8n_translation_votes_on_translation_id_and_translator_i
  ON tr8n_translation_votes
  USING btree
  (translation_id, translator_id);

-- Index: index_tr8n_translation_votes_on_translator_id

-- DROP INDEX index_tr8n_translation_votes_on_translator_id;

CREATE INDEX index_tr8n_translation_votes_on_translator_id
  ON tr8n_translation_votes
  USING btree
  (translator_id);

-- Table: tr8n_translations

-- DROP TABLE tr8n_translations;

CREATE TABLE tr8n_translations
(
  id serial NOT NULL,
  translation_key_id integer NOT NULL,
  language_id integer NOT NULL,
  translator_id integer NOT NULL,
  label text NOT NULL,
  rank integer DEFAULT 0,
  approved_by_id integer,
  dependencies text,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_translations_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_translations OWNER TO postgres;

-- Index: index_tr8n_translations_on_translation_key_id_and_translator_id

-- DROP INDEX index_tr8n_translations_on_translation_key_id_and_translator_id;

CREATE INDEX index_tr8n_translations_on_translation_key_id_and_translator_id
  ON tr8n_translations
  USING btree
  (translation_key_id, translator_id, language_id);

-- Index: index_tr8n_translations_on_translator_id

-- DROP INDEX index_tr8n_translations_on_translator_id;

CREATE INDEX index_tr8n_translations_on_translator_id
  ON tr8n_translations
  USING btree
  (translator_id);

-- Table: tr8n_translator_logs

-- DROP TABLE tr8n_translator_logs;

CREATE TABLE tr8n_translator_logs
(
  id serial NOT NULL,
  translator_id integer,
  user_id integer,
  "action" character varying(255),
  action_level integer,
  reason character varying(255),
  reference character varying(255),
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_translator_logs_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_translator_logs OWNER TO postgres;

-- Index: index_tr8n_translator_logs_on_translator_id

-- DROP INDEX index_tr8n_translator_logs_on_translator_id;

CREATE INDEX index_tr8n_translator_logs_on_translator_id
  ON tr8n_translator_logs
  USING btree
  (translator_id);

-- Index: index_tr8n_translator_logs_on_user_id

-- DROP INDEX index_tr8n_translator_logs_on_user_id;

CREATE INDEX index_tr8n_translator_logs_on_user_id
  ON tr8n_translator_logs
  USING btree
  (user_id);

-- Table: tr8n_translator_metrics

-- DROP TABLE tr8n_translator_metrics;

CREATE TABLE tr8n_translator_metrics
(
  id serial NOT NULL,
  translator_id integer NOT NULL,
  language_id integer,
  total_translations integer DEFAULT 0,
  total_votes integer DEFAULT 0,
  positive_votes integer DEFAULT 0,
  negative_votes integer DEFAULT 0,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_translator_metrics_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_translator_metrics OWNER TO postgres;

-- Index: index_tr8n_translator_metrics_on_translator_id

-- DROP INDEX index_tr8n_translator_metrics_on_translator_id;

CREATE INDEX index_tr8n_translator_metrics_on_translator_id
  ON tr8n_translator_metrics
  USING btree
  (translator_id);

-- Index: index_tr8n_translator_metrics_on_translator_id_and_language_id

-- DROP INDEX index_tr8n_translator_metrics_on_translator_id_and_language_id;

CREATE INDEX index_tr8n_translator_metrics_on_translator_id_and_language_id
  ON tr8n_translator_metrics
  USING btree
  (translator_id, language_id);

-- Table: tr8n_translators

-- DROP TABLE tr8n_translators;

CREATE TABLE tr8n_translators
(
  id serial NOT NULL,
  user_id integer NOT NULL,
  inline_mode boolean DEFAULT false,
  blocked boolean DEFAULT false,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tr8n_translators_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tr8n_translators OWNER TO postgres;

-- Index: index_tr8n_translators_on_user_id

-- DROP INDEX index_tr8n_translators_on_user_id;

CREATE INDEX index_tr8n_translators_on_user_id
  ON tr8n_translators
  USING btree
  (user_id);


