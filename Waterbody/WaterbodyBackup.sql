--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6
-- Dumped by pg_dump version 16.6

-- Started on 2025-02-10 02:09:25 +04

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
-- TOC entry 850 (class 1247 OID 16606)
-- Name: quality; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.quality AS ENUM (
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
);


ALTER TYPE public.quality OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 16627)
-- Name: finances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.finances (
    org_id integer NOT NULL,
    p_id integer NOT NULL,
    amount numeric(8,2) NOT NULL
);


ALTER TABLE public.finances OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16630)
-- Name: organization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization (
    org_id integer NOT NULL,
    org_name character varying(100) NOT NULL
);


ALTER TABLE public.organization OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16633)
-- Name: organization_org_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.organization_org_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organization_org_id_seq OWNER TO postgres;

--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 217
-- Name: organization_org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.organization_org_id_seq OWNED BY public.organization.org_id;


--
-- TOC entry 218 (class 1259 OID 16634)
-- Name: project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project (
    p_id integer NOT NULL,
    p_title character varying(100) NOT NULL,
    t_cost numeric(10,2) NOT NULL,
    startdate date,
    enddate date
);


ALTER TABLE public.project OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16637)
-- Name: project_p_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.project_p_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.project_p_id_seq OWNER TO postgres;

--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 219
-- Name: project_p_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.project_p_id_seq OWNED BY public.project.p_id;


--
-- TOC entry 220 (class 1259 OID 16638)
-- Name: r_water; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r_water (
    rw_id integer NOT NULL,
    rw_name character varying(40) NOT NULL,
    rw_quality public.quality,
    rw_length numeric,
    rw_flows_into integer
);


ALTER TABLE public.r_water OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16643)
-- Name: researcher; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.researcher (
    r_email character varying(80) NOT NULL,
    r_name character varying NOT NULL,
    org_id integer NOT NULL
);


ALTER TABLE public.researcher OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16648)
-- Name: rw_research; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rw_research (
    rw_id integer NOT NULL,
    p_id integer NOT NULL
);


ALTER TABLE public.rw_research OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16651)
-- Name: s_water; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.s_water (
    sw_id integer NOT NULL,
    sw_name character varying(50) NOT NULL,
    sw_quality public.quality NOT NULL,
    surface numeric,
    CONSTRAINT s_water_sw_id_check CHECK (((sw_id >= 2000) AND (sw_id <= 2999)))
);


ALTER TABLE public.s_water OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16657)
-- Name: sw_research; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sw_research (
    sw_id integer NOT NULL,
    p_id integer NOT NULL
);


ALTER TABLE public.sw_research OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16660)
-- Name: works_on; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.works_on (
    r_email character varying(80) NOT NULL,
    p_id integer NOT NULL,
    w_function character varying(100) NOT NULL
);


ALTER TABLE public.works_on OWNER TO postgres;

--
-- TOC entry 3479 (class 2604 OID 16663)
-- Name: organization org_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization ALTER COLUMN org_id SET DEFAULT nextval('public.organization_org_id_seq'::regclass);


--
-- TOC entry 3480 (class 2604 OID 16664)
-- Name: project p_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project ALTER COLUMN p_id SET DEFAULT nextval('public.project_p_id_seq'::regclass);


--
-- TOC entry 3656 (class 0 OID 16627)
-- Dependencies: 215
-- Data for Name: finances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.finances (org_id, p_id, amount) FROM stdin;
2	1	10000.00
2	2	100000.00
2	3	1000.00
3	3	4000.00
4	2	15000.00
\.


--
-- TOC entry 3657 (class 0 OID 16630)
-- Dependencies: 216
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization (org_id, org_name) FROM stdin;
1	GreenGeorgia
2	Nature Bank
3	RiverManagement
4	NatureFund
5	FutureFoundation
\.


--
-- TOC entry 3659 (class 0 OID 16634)
-- Dependencies: 218
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project (p_id, p_title, t_cost, startdate, enddate) FROM stdin;
1	Research on sodium content of water bodies in Georgia.	100000.00	2024-01-03	2025-01-03
2	Improving water quality	2000000.00	2020-01-03	\N
3	Fish wealth	5000.00	2023-03-01	\N
4	Endemic water species	20000.00	2024-08-01	\N
\.


--
-- TOC entry 3661 (class 0 OID 16638)
-- Dependencies: 220
-- Data for Name: r_water; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r_water (rw_id, rw_name, rw_quality, rw_length, rw_flows_into) FROM stdin;
1000	Rioni	2	400	\N
1001	Mtkvari	1	560	\N
1002	Aragvi	5	120	1001
1003	MtisChala	8	\N	1010
1004	Alasani	1	1000	\N
1005	Kvirila	5	\N	1000
1006	WhiteAragvi	5	\N	1002
1007	Lekhura	8	\N	1006
1008	BlackAragvi	7	\N	1002
1009	BzovisTskali	10	\N	1008
1010	Tskatsitela	6	\N	1005
1011	KhevsuretiAragvi	7	\N	1006
1015	Enguri	\N	\N	1000
\.


--
-- TOC entry 3662 (class 0 OID 16643)
-- Dependencies: 221
-- Data for Name: researcher; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.researcher (r_email, r_name, org_id) FROM stdin;
aron@banknature.ge	aron	2
hope@naturefund.ge	hope	4
klopp@gg.ge	klopp	1
lion@mgmtriver.ge	lion	3
lisa@naturefund.ge	lisa	4
neil@mgmtriver.ge	neil	3
summer@naturefund.ge	summer	4
winter@gg.ge	winter	1
\.


--
-- TOC entry 3663 (class 0 OID 16648)
-- Dependencies: 222
-- Data for Name: rw_research; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rw_research (rw_id, p_id) FROM stdin;
1001	1
1004	2
\.


--
-- TOC entry 3664 (class 0 OID 16651)
-- Dependencies: 223
-- Data for Name: s_water; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.s_water (sw_id, sw_name, sw_quality, surface) FROM stdin;
2000	KIU_lake	10	\N
2001	KoditskaroLake	9	\N
2002	Parawani	9	\N
2003	SaghamoLake	8	\N
2005	Lisi Lake	4	\N
2010	Lake Tabatsquri	8	\N
\.


--
-- TOC entry 3665 (class 0 OID 16657)
-- Dependencies: 224
-- Data for Name: sw_research; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sw_research (sw_id, p_id) FROM stdin;
2000	1
2001	1
\.


--
-- TOC entry 3666 (class 0 OID 16660)
-- Dependencies: 225
-- Data for Name: works_on; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.works_on (r_email, p_id, w_function) FROM stdin;
aron@banknature.ge	2	Controller
hope@naturefund.ge	2	Project Manager
klopp@gg.ge	1	Project Manager
klopp@gg.ge	4	Data Specialist
lisa@naturefund.ge	2	Specialist
summer@naturefund.ge	2	Specialist
summer@naturefund.ge	4	Project Manager
\.


--
-- TOC entry 3674 (class 0 OID 0)
-- Dependencies: 217
-- Name: organization_org_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.organization_org_id_seq', 1, false);


--
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 219
-- Name: project_p_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.project_p_id_seq', 1, false);


--
-- TOC entry 3486 (class 2606 OID 16666)
-- Name: finances finances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finances
    ADD CONSTRAINT finances_pkey PRIMARY KEY (org_id, p_id);


--
-- TOC entry 3488 (class 2606 OID 16668)
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (org_id);


--
-- TOC entry 3481 (class 2606 OID 16669)
-- Name: project project_check; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.project
    ADD CONSTRAINT project_check CHECK (((startdate IS NULL) OR (enddate IS NULL) OR (enddate > startdate))) NOT VALID;


--
-- TOC entry 3490 (class 2606 OID 16671)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (p_id);


--
-- TOC entry 3482 (class 2606 OID 16672)
-- Name: r_water r_water_check; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.r_water
    ADD CONSTRAINT r_water_check CHECK ((rw_flows_into IS DISTINCT FROM rw_id)) NOT VALID;


--
-- TOC entry 3492 (class 2606 OID 16674)
-- Name: r_water r_water_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r_water
    ADD CONSTRAINT r_water_pkey PRIMARY KEY (rw_id);


--
-- TOC entry 3483 (class 2606 OID 16675)
-- Name: r_water r_water_rw_id_check; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.r_water
    ADD CONSTRAINT r_water_rw_id_check CHECK (((rw_id >= 1000) AND (rw_id <= 1999))) NOT VALID;


--
-- TOC entry 3494 (class 2606 OID 16677)
-- Name: researcher researcher_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.researcher
    ADD CONSTRAINT researcher_pkey PRIMARY KEY (r_email);


--
-- TOC entry 3496 (class 2606 OID 16679)
-- Name: rw_research rw_research_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rw_research
    ADD CONSTRAINT rw_research_pkey PRIMARY KEY (rw_id, p_id);


--
-- TOC entry 3498 (class 2606 OID 16681)
-- Name: s_water s_water_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.s_water
    ADD CONSTRAINT s_water_pkey PRIMARY KEY (sw_id);


--
-- TOC entry 3500 (class 2606 OID 16683)
-- Name: sw_research sw_research_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sw_research
    ADD CONSTRAINT sw_research_pkey PRIMARY KEY (sw_id, p_id);


--
-- TOC entry 3502 (class 2606 OID 16685)
-- Name: works_on works_on_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.works_on
    ADD CONSTRAINT works_on_pkey PRIMARY KEY (r_email, p_id);


--
-- TOC entry 3503 (class 2606 OID 16686)
-- Name: finances finances_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finances
    ADD CONSTRAINT finances_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(org_id) ON UPDATE CASCADE;


--
-- TOC entry 3504 (class 2606 OID 16691)
-- Name: finances finances_p_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finances
    ADD CONSTRAINT finances_p_id_fkey FOREIGN KEY (p_id) REFERENCES public.project(p_id) ON UPDATE CASCADE;


--
-- TOC entry 3505 (class 2606 OID 16696)
-- Name: r_water r_water_flows_into_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r_water
    ADD CONSTRAINT r_water_flows_into_fkey FOREIGN KEY (rw_flows_into) REFERENCES public.r_water(rw_id) ON UPDATE CASCADE NOT VALID;


--
-- TOC entry 3506 (class 2606 OID 16701)
-- Name: researcher researcher_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.researcher
    ADD CONSTRAINT researcher_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(org_id) ON UPDATE CASCADE;


--
-- TOC entry 3507 (class 2606 OID 16706)
-- Name: rw_research rw_research_p_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rw_research
    ADD CONSTRAINT rw_research_p_id_fkey FOREIGN KEY (p_id) REFERENCES public.project(p_id) ON UPDATE CASCADE;


--
-- TOC entry 3508 (class 2606 OID 16711)
-- Name: rw_research rw_research_rw_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rw_research
    ADD CONSTRAINT rw_research_rw_id_fkey FOREIGN KEY (rw_id) REFERENCES public.r_water(rw_id) ON UPDATE CASCADE;


--
-- TOC entry 3509 (class 2606 OID 16716)
-- Name: sw_research sw_research_p_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sw_research
    ADD CONSTRAINT sw_research_p_id_fkey FOREIGN KEY (p_id) REFERENCES public.project(p_id) ON UPDATE CASCADE;


--
-- TOC entry 3510 (class 2606 OID 16721)
-- Name: sw_research sw_research_sw_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sw_research
    ADD CONSTRAINT sw_research_sw_id_fkey FOREIGN KEY (sw_id) REFERENCES public.s_water(sw_id) ON UPDATE CASCADE;


--
-- TOC entry 3511 (class 2606 OID 16726)
-- Name: works_on works_on_p_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.works_on
    ADD CONSTRAINT works_on_p_id_fkey FOREIGN KEY (p_id) REFERENCES public.project(p_id) ON UPDATE CASCADE;


--
-- TOC entry 3512 (class 2606 OID 16731)
-- Name: works_on works_on_r_email_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.works_on
    ADD CONSTRAINT works_on_r_email_fkey FOREIGN KEY (r_email) REFERENCES public.researcher(r_email) ON UPDATE CASCADE;


-- Completed on 2025-02-10 02:09:25 +04

--
-- PostgreSQL database dump complete
--

