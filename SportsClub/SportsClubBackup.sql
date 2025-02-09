--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6
-- Dumped by pg_dump version 16.6

-- Started on 2025-02-10 01:36:50 +04

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
-- TOC entry 852 (class 1247 OID 16495)
-- Name: gender; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.gender AS ENUM (
    'f',
    'm',
    'd'
);


ALTER TYPE public.gender OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 16817)
-- Name: fn_check_parent_of_child(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_check_parent_of_child() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		IF EXTRACT(YEAR FROM AGE(NEW.birthday)) < 18 AND NEW.parent IS NULL THEN
			RAISE EXCEPTION 'child must have a parent!';
		END IF;
	END;
	$$;


ALTER FUNCTION public.fn_check_parent_of_child() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 16501)
-- Name: area; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.area (
    area character(10) NOT NULL,
    description character varying(80),
    manager character varying(20)
);


ALTER TABLE public.area OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16504)
-- Name: course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course (
    course_id integer NOT NULL,
    course_name character varying NOT NULL,
    targetgroup character(3) NOT NULL,
    area character(10),
    trainer character varying(20) NOT NULL
);


ALTER TABLE public.course OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16807)
-- Name: area_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.area_view AS
 SELECT a.area,
    count(c.*) AS number_of_courses,
    string_agg((c.course_name)::text, ','::text) AS string_agg,
    (((count(c.course_id))::numeric * 100.0) / sum(count(c.course_id)) OVER ()) AS percentage
   FROM (public.area a
     JOIN public.course c ON ((a.area = c.area)))
  GROUP BY a.area;


ALTER VIEW public.area_view OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16509)
-- Name: course_course_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.course_course_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.course_course_id_seq OWNER TO postgres;

--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 217
-- Name: course_course_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.course_course_id_seq OWNED BY public.course.course_id;


--
-- TOC entry 218 (class 1259 OID 16510)
-- Name: device; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device (
    device_id integer NOT NULL,
    description character varying(50) NOT NULL
);


ALTER TABLE public.device OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16513)
-- Name: device_device_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.device_device_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.device_device_id_seq OWNER TO postgres;

--
-- TOC entry 3681 (class 0 OID 0)
-- Dependencies: 219
-- Name: device_device_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.device_device_id_seq OWNED BY public.device.device_id;


--
-- TOC entry 220 (class 1259 OID 16514)
-- Name: enrollment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enrollment (
    memname character varying(20) NOT NULL,
    course_id integer NOT NULL
);


ALTER TABLE public.enrollment OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16517)
-- Name: member; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.member (
    memname character varying(20) NOT NULL,
    is_trainer boolean DEFAULT false NOT NULL,
    email character varying(50) NOT NULL,
    postalcode integer NOT NULL,
    birthday date,
    gender public.gender NOT NULL,
    entry_date date,
    parent character varying(20)
);


ALTER TABLE public.member OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16521)
-- Name: reservation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservation (
    memname character varying(20) NOT NULL,
    timeslot timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    device_id integer NOT NULL
);


ALTER TABLE public.reservation OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16525)
-- Name: targetgroup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.targetgroup (
    targetgroup character(3) NOT NULL,
    description character varying(60)
);


ALTER TABLE public.targetgroup OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16528)
-- Name: trainer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trainer (
    tname character varying(20) NOT NULL,
    license boolean DEFAULT false,
    start_date date
);


ALTER TABLE public.trainer OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16812)
-- Name: trainer_info; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.trainer_info AS
 SELECT t.tname,
    m.birthday,
    EXTRACT(year FROM age((m.birthday)::timestamp with time zone)) AS age,
    m.gender,
    m.email,
    m.entry_date,
    t.license,
    t.start_date
   FROM (public.trainer t
     JOIN public.member m ON (((m.memname)::text = (t.tname)::text)));


ALTER VIEW public.trainer_info OWNER TO postgres;

--
-- TOC entry 3484 (class 2604 OID 16532)
-- Name: course course_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course ALTER COLUMN course_id SET DEFAULT nextval('public.course_course_id_seq'::regclass);


--
-- TOC entry 3485 (class 2604 OID 16533)
-- Name: device device_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device ALTER COLUMN device_id SET DEFAULT nextval('public.device_device_id_seq'::regclass);


--
-- TOC entry 3665 (class 0 OID 16501)
-- Dependencies: 215
-- Data for Name: area; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.area (area, description, manager) FROM stdin;
athletics 	High jump, long jump, decathlon, penthalon, sprint distances and the like	nelly
martialArt	Wrestling, Judo and the like	klopp
watersport	All sports that have to do with water	lazy
fitness   	Comprises all courses that encrease healthy lifestyle and fitness	eva_knirsch
\.


--
-- TOC entry 3666 (class 0 OID 16504)
-- Dependencies: 216
-- Data for Name: course; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course (course_id, course_name, targetgroup, area, trainer) FROM stdin;
1	wrestling	men	martialArt	klopp
2	waterball	men	watersport	klopp
4	jogging	fam	fitness   	lena
5	fitnessKids	kid	fitness   	klopp
6	high jump	fam	athletics 	lena
7	obstacle race	fam	athletics 	lena
9	free style	kid	watersport	lazy
10	aerobics	fam	fitness   	lena
15	gymnastics water	all	watersport	lena
3	running	men	fitness   	lazy
8	swimming	fam	watersport	lena
\.


--
-- TOC entry 3668 (class 0 OID 16510)
-- Dependencies: 218
-- Data for Name: device; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.device (device_id, description) FROM stdin;
1	treadmill
2	rowing machine
\.


--
-- TOC entry 3670 (class 0 OID 16514)
-- Dependencies: 220
-- Data for Name: enrollment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enrollment (memname, course_id) FROM stdin;
lion	1
lion	4
lion	5
lion	6
lion	7
lion	10
lisa	6
lisa	9
nelly	1
nelly	4
nelly	5
nelly	6
nelly	7
nelly	10
robin	1
robin	4
robin	5
robin	6
robin	7
robin	10
rose	4
rose	5
rose	6
rose	7
rose	10
val	1
val	4
val	5
val	6
valerie	1
valerie	4
valerie	5
valerie	6
valerie	7
valerie	10
figaro	1
hope	1
hope	5
hope	6
hope	7
hope	10
\.


--
-- TOC entry 3671 (class 0 OID 16517)
-- Dependencies: 221
-- Data for Name: member; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.member (memname, is_trainer, email, postalcode, birthday, gender, entry_date, parent) FROM stdin;
coach	t	coach@xx.ge	4565	1988-12-01	m	\N	\N
figaro	f	figaro@xx.ge	3674	1989-05-07	m	\N	\N
lazy	t	lazy@xx.ge	4600	1996-11-25	m	\N	\N
lena	t	lena@xx.ge	105	1995-01-25	f	\N	\N
lion	f	lion@xxx.ge	103	1990-10-10	m	\N	\N
nelly	t	luke@xx.ge	4565	1990-04-21	f	\N	\N
valerie	f	val@xx.ge	105	1970-03-20	f	\N	\N
robin	f	nelly@xx.ge	4600	2012-09-16	m	2017-01-01	nelly
rose	f	lion@xx.ge	107	2015-02-10	f	\N	lion
val	f	val@xx.ge	103	2013-07-12	m	2020-05-01	figaro
aron	f	klopp@xx.ge	103	2013-11-06	m	2020-01-01	klopp
lisa	f	figaro@xx.ge	4600	2015-11-19	f	\N	figaro
eva_knirsch	t	eva.knirsch@xx.ge	4600	\N	f	\N	\N
hope	f	hope@xx.ge	4565	1965-09-14	f	2016-03-01	\N
luke	f	luke@xxx.ge	4565	1998-11-22	m	\N	hope
klopp	t	klopp@xx.ge	4600	1980-12-24	m	2018-01-01	\N
\.


--
-- TOC entry 3672 (class 0 OID 16521)
-- Dependencies: 222
-- Data for Name: reservation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservation (memname, timeslot, device_id) FROM stdin;
klopp	2024-10-14 14:53:15.562498	2
figaro	2024-10-14 14:53:15.562498	1
eva_knirsch	2024-10-19 09:42:43.9336	1
hope	2024-10-13 21:14:42.426565	1
\.


--
-- TOC entry 3673 (class 0 OID 16525)
-- Dependencies: 223
-- Data for Name: targetgroup; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.targetgroup (targetgroup, description) FROM stdin;
all	everybody
fam	families
kid	kinds up to 10
jun	young people 10 - 20
sen	seniors
men	courses for men
wom	courses for women
\.


--
-- TOC entry 3674 (class 0 OID 16528)
-- Dependencies: 224
-- Data for Name: trainer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trainer (tname, license, start_date) FROM stdin;
coach	t	2021-10-01
klopp	t	\N
lazy	t	\N
lena	f	\N
nelly	f	\N
eva_knirsch	t	2024-01-01
\.


--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 217
-- Name: course_course_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.course_course_id_seq', 15, true);


--
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 219
-- Name: device_device_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.device_device_id_seq', 1, false);


--
-- TOC entry 3490 (class 2606 OID 16535)
-- Name: area area_manager_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_manager_key UNIQUE (manager);


--
-- TOC entry 3492 (class 2606 OID 16537)
-- Name: area area_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_pkey PRIMARY KEY (area);


--
-- TOC entry 3494 (class 2606 OID 16539)
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (course_id);


--
-- TOC entry 3496 (class 2606 OID 16541)
-- Name: device device_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (device_id);


--
-- TOC entry 3498 (class 2606 OID 16543)
-- Name: enrollment enrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_pkey PRIMARY KEY (memname, course_id);


--
-- TOC entry 3500 (class 2606 OID 16545)
-- Name: member mem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT mem_pkey PRIMARY KEY (memname);


--
-- TOC entry 3502 (class 2606 OID 16547)
-- Name: reservation reservation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_pkey PRIMARY KEY (memname, timeslot);


--
-- TOC entry 3504 (class 2606 OID 16549)
-- Name: reservation reservation_timeslot_device_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_timeslot_device_id_key UNIQUE (timeslot, device_id);


--
-- TOC entry 3506 (class 2606 OID 16551)
-- Name: targetgroup targetgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.targetgroup
    ADD CONSTRAINT targetgroup_pkey PRIMARY KEY (targetgroup);


--
-- TOC entry 3508 (class 2606 OID 16553)
-- Name: trainer trainer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainer
    ADD CONSTRAINT trainer_pkey PRIMARY KEY (tname);


--
-- TOC entry 3519 (class 2620 OID 16818)
-- Name: member tr_insert_child; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_insert_child BEFORE INSERT ON public.member FOR EACH ROW EXECUTE FUNCTION public.fn_check_parent_of_child();


--
-- TOC entry 3509 (class 2606 OID 16554)
-- Name: area area_manager_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_manager_fkey FOREIGN KEY (manager) REFERENCES public.trainer(tname) ON UPDATE SET NULL ON DELETE SET NULL NOT VALID;


--
-- TOC entry 3510 (class 2606 OID 16559)
-- Name: course course_area_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_area_fkey FOREIGN KEY (area) REFERENCES public.area(area) ON UPDATE CASCADE ON DELETE SET NULL NOT VALID;


--
-- TOC entry 3511 (class 2606 OID 16564)
-- Name: course course_targetgroup_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_targetgroup_fkey FOREIGN KEY (targetgroup) REFERENCES public.targetgroup(targetgroup);


--
-- TOC entry 3512 (class 2606 OID 16569)
-- Name: course course_trainer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_trainer_fkey FOREIGN KEY (trainer) REFERENCES public.trainer(tname);


--
-- TOC entry 3513 (class 2606 OID 16574)
-- Name: enrollment enrollment_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.course(course_id);


--
-- TOC entry 3514 (class 2606 OID 16579)
-- Name: enrollment enrollment_memname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_memname_fkey FOREIGN KEY (memname) REFERENCES public.member(memname) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3515 (class 2606 OID 16584)
-- Name: member member_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_parent_fkey FOREIGN KEY (parent) REFERENCES public.member(memname) ON UPDATE CASCADE NOT VALID;


--
-- TOC entry 3516 (class 2606 OID 16589)
-- Name: reservation reservation_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(device_id);


--
-- TOC entry 3517 (class 2606 OID 16594)
-- Name: reservation reservation_memname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_memname_fkey FOREIGN KEY (memname) REFERENCES public.member(memname) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3518 (class 2606 OID 16599)
-- Name: trainer trainer_tname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainer
    ADD CONSTRAINT trainer_tname_fkey FOREIGN KEY (tname) REFERENCES public.member(memname) NOT VALID;


-- Completed on 2025-02-10 01:36:51 +04

--
-- PostgreSQL database dump complete
--

