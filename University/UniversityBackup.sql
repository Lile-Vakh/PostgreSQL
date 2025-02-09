--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6
-- Dumped by pg_dump version 16.6

-- Started on 2025-02-10 01:59:41 +04

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 227 (class 1255 OID 16842)
-- Name: fn_log_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_log_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO log_exam(all_old_values, all_new_values)
		VALUES (ROW(OLD.*), ROW(NEW.*));
	END;
	$$;


ALTER FUNCTION public.fn_log_update() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 16845)
-- Name: generate_email(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_email() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		NEW.student_email = NEW.name || '.' || NEW.semester || '@kiu.edu.ge';
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION public.generate_email() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 16400)
-- Name: assistant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assistant (
    assistant_i_d bigint NOT NULL,
    name character varying(50) NOT NULL,
    research_area character varying(80),
    prof_i_d bigint
);


ALTER TABLE public.assistant OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16403)
-- Name: assistant_assistant_i_d_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.assistant_assistant_i_d_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.assistant_assistant_i_d_seq OWNER TO postgres;

--
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 216
-- Name: assistant_assistant_i_d_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.assistant_assistant_i_d_seq OWNED BY public.assistant.assistant_i_d;


--
-- TOC entry 217 (class 1259 OID 16404)
-- Name: course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course (
    course_i_d bigint NOT NULL,
    title character varying(50) NOT NULL,
    contact_hours smallint NOT NULL,
    prof_i_d bigint
);


ALTER TABLE public.course OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16407)
-- Name: enrollment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enrollment (
    stud_i_d bigint NOT NULL,
    course_i_d bigint NOT NULL
);


ALTER TABLE public.enrollment OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16410)
-- Name: examination; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.examination (
    stud_i_d bigint NOT NULL,
    course_i_d bigint NOT NULL,
    prof_i_d bigint NOT NULL,
    grade character varying NOT NULL,
    points smallint
);


ALTER TABLE public.examination OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16831)
-- Name: log_exam; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_exam (
    id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "current_user" character varying(50) DEFAULT CURRENT_USER NOT NULL,
    all_old_values character varying(255) NOT NULL,
    all_new_values character varying(255) NOT NULL
);


ALTER TABLE public.log_exam OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16830)
-- Name: log_exam_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_exam_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_exam_id_seq OWNER TO postgres;

--
-- TOC entry 3684 (class 0 OID 0)
-- Dependencies: 225
-- Name: log_exam_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_exam_id_seq OWNED BY public.log_exam.id;


--
-- TOC entry 220 (class 1259 OID 16415)
-- Name: professor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.professor (
    prof_i_d bigint NOT NULL,
    name character varying(50) NOT NULL,
    rank character(2)
);


ALTER TABLE public.professor OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16421)
-- Name: student; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student (
    stud_i_d bigint NOT NULL,
    name character varying(50) NOT NULL,
    semester smallint,
    student_email character varying(60)
);


ALTER TABLE public.student OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16740)
-- Name: mat_view_enroll; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mat_view_enroll AS
 SELECT c.course_i_d,
    c.title,
    p.name AS professor,
    s.name,
    e.stud_i_d,
    s.semester
   FROM (((public.course c
     JOIN public.professor p ON ((c.prof_i_d = p.prof_i_d)))
     JOIN public.enrollment e ON ((c.course_i_d = e.course_i_d)))
     JOIN public.student s ON ((s.stud_i_d = e.stud_i_d)))
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mat_view_enroll OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16418)
-- Name: requirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.requirement (
    predecessor bigint NOT NULL,
    successor bigint NOT NULL
);


ALTER TABLE public.requirement OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16736)
-- Name: view_enroll; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_enroll AS
 SELECT c.course_i_d,
    c.title,
    p.name AS professor,
    s.name,
    e.stud_i_d,
    s.semester
   FROM (((public.course c
     JOIN public.professor p ON ((c.prof_i_d = p.prof_i_d)))
     JOIN public.enrollment e ON ((c.course_i_d = e.course_i_d)))
     JOIN public.student s ON ((s.stud_i_d = e.stud_i_d)));


ALTER VIEW public.view_enroll OWNER TO postgres;

--
-- TOC entry 3482 (class 2604 OID 16424)
-- Name: assistant assistant_i_d; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assistant ALTER COLUMN assistant_i_d SET DEFAULT nextval('public.assistant_assistant_i_d_seq'::regclass);


--
-- TOC entry 3483 (class 2604 OID 16834)
-- Name: log_exam id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_exam ALTER COLUMN id SET DEFAULT nextval('public.log_exam_id_seq'::regclass);


--
-- TOC entry 3667 (class 0 OID 16400)
-- Dependencies: 215
-- Data for Name: assistant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assistant (assistant_i_d, name, research_area, prof_i_d) FROM stdin;
3002	Platon	Ideology	2125
3003	Aristoteles	Logic	2125
3004	Wittgenstein	Speech Theorie	2126
3005	Rhetikus	Movement of Planets	2127
3006	Newton	Kepler's laws	2127
3007	Spinoza	God and Nature	2134
\.


--
-- TOC entry 3669 (class 0 OID 16404)
-- Dependencies: 217
-- Data for Name: course; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course (course_i_d, title, contact_hours, prof_i_d) FROM stdin;
4052	Logic	4	2125
4630	Three Critics	4	2137
5001	Foundation	4	2137
5022	Science and Faith	2	2134
5041	Ethics	4	2125
5043	Cognition Theory	3	2126
5049	maieutics	2	2125
5052	philosophy of science	3	2126
5216	Bioethics	2	2126
5259	Vienna Circle	2	2133
\.


--
-- TOC entry 3670 (class 0 OID 16407)
-- Dependencies: 218
-- Data for Name: enrollment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enrollment (stud_i_d, course_i_d) FROM stdin;
25403	5022
26120	5001
27550	4052
27550	5001
28106	5041
28106	5052
28106	5216
28106	5259
29120	4052
29120	4630
29120	5001
29120	5041
29120	5049
29555	5001
29555	5022
\.


--
-- TOC entry 3671 (class 0 OID 16410)
-- Dependencies: 219
-- Data for Name: examination; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.examination (stud_i_d, course_i_d, prof_i_d, grade, points) FROM stdin;
25403	5001	2126	B	85
25403	5041	2125	B	81
26120	5001	2126	B	88
26830	5001	2126	C	75
27550	4630	2137	E	51
27550	5001	2126	C	74
28106	5001	2126	A	95
29555	5001	2126	E	40
\.


--
-- TOC entry 3677 (class 0 OID 16831)
-- Dependencies: 226
-- Data for Name: log_exam; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_exam (id, "timestamp", "current_user", all_old_values, all_new_values) FROM stdin;
\.


--
-- TOC entry 3672 (class 0 OID 16415)
-- Dependencies: 220
-- Data for Name: professor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.professor (prof_i_d, name, rank) FROM stdin;
2125	Sokrates	C4
2126	Russel	C4
2127	Kopernikus	C3
2133	Popper	C3
2134	Augustinus	C3
2136	Curie	C4
2137	Kant	C4
\.


--
-- TOC entry 3673 (class 0 OID 16418)
-- Dependencies: 221
-- Data for Name: requirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.requirement (predecessor, successor) FROM stdin;
5041	4630
4052	5049
5041	5049
5259	5052
4630	5259
\.


--
-- TOC entry 3674 (class 0 OID 16421)
-- Dependencies: 222
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student (stud_i_d, name, semester, student_email) FROM stdin;
24002	Xenokrates	18	\N
24100	Jonas	\N	Jonas@kiu.edu.ge
24101	Jonas	\N	Jonas1@kiu.edu.ge
24102	Jonas	\N	Jonas2@kiu.edu.ge
25403	Jonas	12	\N
26120	Fichte	10	\N
26830	Aristoxenos	\N	\N
27550	Schopenhauer	0	\N
28106	Carnap	\N	\N
29120	Theophrastos	0	\N
29555	Feuerbach	\N	\N
29990	Hegel	0	Hegel@kiu.edu.ge
29991	Hegel	0	Hegel1@kiu.edu.ge
29992	Hegel	0	Hegel2@kiu.edu.ge
2303	Lile	7	lile.7@kiu.edu.ge
230	Lile	7	Lile.7@kiu.edu.ge
\.


--
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 216
-- Name: assistant_assistant_i_d_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.assistant_assistant_i_d_seq', 3007, true);


--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 225
-- Name: log_exam_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_exam_id_seq', 1, true);


--
-- TOC entry 3489 (class 2606 OID 16426)
-- Name: assistant assistant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assistant
    ADD CONSTRAINT assistant_pkey PRIMARY KEY (assistant_i_d);


--
-- TOC entry 3492 (class 2606 OID 16428)
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (course_i_d);


--
-- TOC entry 3495 (class 2606 OID 16430)
-- Name: enrollment enrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_pkey PRIMARY KEY (course_i_d, stud_i_d);


--
-- TOC entry 3499 (class 2606 OID 16432)
-- Name: examination examination_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.examination
    ADD CONSTRAINT examination_pkey PRIMARY KEY (stud_i_d, course_i_d);


--
-- TOC entry 3510 (class 2606 OID 16840)
-- Name: log_exam log_exam_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_exam
    ADD CONSTRAINT log_exam_pkey PRIMARY KEY (id);


--
-- TOC entry 3502 (class 2606 OID 16434)
-- Name: professor professor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professor
    ADD CONSTRAINT professor_pkey PRIMARY KEY (prof_i_d);


--
-- TOC entry 3505 (class 2606 OID 16436)
-- Name: requirement requirement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requirement
    ADD CONSTRAINT requirement_pkey PRIMARY KEY (predecessor, successor);


--
-- TOC entry 3507 (class 2606 OID 16438)
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (stud_i_d);


--
-- TOC entry 3486 (class 2606 OID 16439)
-- Name: student student_semester_check; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.student
    ADD CONSTRAINT student_semester_check CHECK (((semester >= 1) AND (semester <= 12))) NOT VALID;


--
-- TOC entry 3487 (class 1259 OID 16440)
-- Name: assistant_f_k_prof_i_d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX assistant_f_k_prof_i_d ON public.assistant USING btree (prof_i_d);


--
-- TOC entry 3490 (class 1259 OID 16441)
-- Name: course_f_k_course_professor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX course_f_k_course_professor ON public.course USING btree (prof_i_d);


--
-- TOC entry 3493 (class 1259 OID 16442)
-- Name: enrollment_f_k_enrollment_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX enrollment_f_k_enrollment_student ON public.enrollment USING btree (stud_i_d);


--
-- TOC entry 3496 (class 1259 OID 16443)
-- Name: examination_f_k__course; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX examination_f_k__course ON public.examination USING btree (course_i_d);


--
-- TOC entry 3497 (class 1259 OID 16444)
-- Name: examination_f_k__professor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX examination_f_k__professor ON public.examination USING btree (prof_i_d);


--
-- TOC entry 3500 (class 1259 OID 16445)
-- Name: professor_index_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX professor_index_name ON public.professor USING btree (name);


--
-- TOC entry 3503 (class 1259 OID 16446)
-- Name: requirement_f_k_requirement_course_2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX requirement_f_k_requirement_course_2 ON public.requirement USING btree (successor);


--
-- TOC entry 3508 (class 1259 OID 16447)
-- Name: student_student_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX student_student_name ON public.student USING btree (name);


--
-- TOC entry 3521 (class 2620 OID 16846)
-- Name: student email_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER email_trigger BEFORE INSERT ON public.student FOR EACH ROW EXECUTE FUNCTION public.generate_email();


--
-- TOC entry 3520 (class 2620 OID 16843)
-- Name: examination examination_after_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER examination_after_update AFTER UPDATE ON public.examination FOR EACH ROW EXECUTE FUNCTION public.fn_log_update();


--
-- TOC entry 3515 (class 2606 OID 16448)
-- Name: examination f_k__course; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.examination
    ADD CONSTRAINT f_k__course FOREIGN KEY (course_i_d) REFERENCES public.course(course_i_d);


--
-- TOC entry 3516 (class 2606 OID 16453)
-- Name: examination f_k__professor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.examination
    ADD CONSTRAINT f_k__professor FOREIGN KEY (prof_i_d) REFERENCES public.professor(prof_i_d);


--
-- TOC entry 3517 (class 2606 OID 16458)
-- Name: examination f_k__student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.examination
    ADD CONSTRAINT f_k__student FOREIGN KEY (stud_i_d) REFERENCES public.student(stud_i_d);


--
-- TOC entry 3511 (class 2606 OID 16463)
-- Name: assistant f_k_assistant_professor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assistant
    ADD CONSTRAINT f_k_assistant_professor FOREIGN KEY (prof_i_d) REFERENCES public.professor(prof_i_d);


--
-- TOC entry 3512 (class 2606 OID 16468)
-- Name: course f_k_course_professor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT f_k_course_professor FOREIGN KEY (prof_i_d) REFERENCES public.professor(prof_i_d);


--
-- TOC entry 3513 (class 2606 OID 16473)
-- Name: enrollment f_k_enrollment_course; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT f_k_enrollment_course FOREIGN KEY (course_i_d) REFERENCES public.course(course_i_d);


--
-- TOC entry 3514 (class 2606 OID 16478)
-- Name: enrollment f_k_enrollment_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT f_k_enrollment_student FOREIGN KEY (stud_i_d) REFERENCES public.student(stud_i_d);


--
-- TOC entry 3518 (class 2606 OID 16483)
-- Name: requirement f_k_requirement_course; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requirement
    ADD CONSTRAINT f_k_requirement_course FOREIGN KEY (predecessor) REFERENCES public.course(course_i_d);


--
-- TOC entry 3519 (class 2606 OID 16488)
-- Name: requirement f_k_requirement_course_2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requirement
    ADD CONSTRAINT f_k_requirement_course_2 FOREIGN KEY (successor) REFERENCES public.course(course_i_d);


--
-- TOC entry 3675 (class 0 OID 16740)
-- Dependencies: 224 3679
-- Name: mat_view_enroll; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mat_view_enroll;


-- Completed on 2025-02-10 01:59:41 +04

--
-- PostgreSQL database dump complete
--

