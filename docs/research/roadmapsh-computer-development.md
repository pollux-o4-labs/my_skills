# roadmap.sh computer/software-development roadmap review

Date checked: 2026-08-28

## Scope and classification

roadmap.sh describes itself as a source of community-driven paths for learning a tool or technology, and separates role-based from skill-based roadmaps. Its current catalog groups material under Web Development, DevOps, Databases, Computer Science, and related areas: [roadmaps catalog](https://roadmap.sh/roadmaps/). The companion repository says its `roadmaps/<slug>/content/` files are the website’s topic content and that merged changes sync to the site: [official repository](https://github.com/nilbuild/developer-roadmap).

For skills organized around principles, treat a **technical track** as a durable capability or problem domain (for example, API design or quality engineering). Treat a **tool/technology track** as a named language, framework, platform, database, protocol, or product (for example, Python, React, Docker, or PostgreSQL). Tool tracks are best used as examples, exercises, or implementation adapters inside a principle-based skill.

## Recommended bounded set of technical domains

| Domain suitable for a principle-based skill | Actionable focus visible in roadmap.sh | Classification |
|---|---|---|
| Computer-science foundations | How computers work, processes/threads, networking, databases, security, systems concepts | Technical track — [Computer Science](https://roadmap.sh/computer-science) and [PDF nodes](https://roadmap.sh/pdfs/roadmaps/computer-science.pdf) |
| Data structures and algorithms | Complexity, core structures, searching/sorting, graphs, recursion, caching | Technical track — [DSA PDF](https://roadmap.sh/pdfs/roadmaps/datastructures-and-algorithms.pdf) |
| Frontend/web application development | Semantic HTML, accessibility, responsive CSS, JavaScript, browser APIs, performance, testing, security | Technical track — [Frontend](https://roadmap.sh/frontend) and [PDF nodes](https://roadmap.sh/pdfs/roadmaps/frontend.pdf) |
| Backend/service development | Server logic, APIs, persistence, authentication/authorization, performance, scalability, external services | Technical track — [Backend](https://roadmap.sh/backend) and [Backend PDF](https://roadmap.sh/pdfs/roadmaps/backend.pdf) |
| API design and integration | HTTP, API styles, resource/version design, errors, auth, rate limits, async/event integration, contract testing | Technical track — [API Design](https://roadmap.sh/api-design) and [PDF nodes](https://roadmap.sh/pdfs/roadmaps/api-design.pdf) |
| Software design and architecture | Clean code, paradigms, OOP, SOLID/DRY/YAGNI, design patterns, DDD, architectural styles/patterns | Technical track — [Software Design & Architecture](https://roadmap.sh/software-design-architecture) and [PDF nodes](https://roadmap.sh/pdfs/roadmaps/software-design-architecture.pdf) |
| System design and distributed systems | Requirements, scaling, load balancing, caching, queues, communication, reliability, observability, security | Technical track — [System Design](https://roadmap.sh/system-design) and [PDF nodes](https://roadmap.sh/pdfs/roadmaps/system-design.pdf) |
| Quality engineering/testing | Test strategy, oracles/prioritization, functional and non-functional testing, automation, reporting, CI/CD | Technical track — [QA](https://roadmap.sh/qa) and [QA PDF](https://roadmap.sh/pdfs/roadmaps/qa.pdf) |
| DevOps/SRE and software delivery | Linux/networking, source control, CI/CD, infrastructure as code, containers, orchestration, monitoring/logging, cloud patterns | Technical track — [DevOps](https://roadmap.sh/devops) and [DevOps PDF](https://roadmap.sh/pdfs/roadmaps/devops.pdf) |
| Application security and DevSecOps | Threats, secure protocols, identity, secrets, hardening, vulnerability management, secure delivery, incident response | Technical track — [Cyber Security PDF](https://roadmap.sh/pdfs/roadmaps/cyber-security.pdf) and [DevSecOps](https://roadmap.sh/r/devsecops-88a05) |

These ten form a coherent core: foundations inform implementation; frontend/backend/API cover application construction; architecture/system design cover structure and scale; QA, DevOps, and security cover confidence and operation. This grouping is an inference from the roadmap relationships and repeated cross-links, not an official roadmap.sh taxonomy.

## Scoped extensions

If the skills collection covers more than general software development, add **mobile application development** ([Android](https://roadmap.sh/android), [Android PDF](https://roadmap.sh/pdfs/roadmaps/android.pdf)) and **AI application engineering** ([AI Engineer](https://roadmap.sh/ai-engineer), [AI Engineer PDF](https://roadmap.sh/pdfs/roadmaps/ai-engineer.pdf)) as technical tracks. Their roadmaps are actionable, but they introduce platform/model-specific concerns and are better kept separate from the core set. Data Engineer and MLOps are similarly valid specialist tracks in the official repository/catalog, but are narrower extensions: [Data Engineer](https://roadmap.sh/data-engineer), [MLOps](https://roadmap.sh/mlops).

## Tool/technology tracks to keep distinct

The catalog also lists implementation-specific roadmaps. Do not make each of these a separate principle-based domain:

- Languages/platforms: HTML, CSS, JavaScript, TypeScript, Python, Java, C/C++, Rust, Go, PHP, Kotlin, Swift, Shell/Bash, Node.js.
- Frameworks/runtimes: React, Vue, Angular, Next.js, Django, Spring Boot, Laravel, ASP.NET Core, Flutter, React Native.
- Infrastructure/platform tools: Linux, Docker, Kubernetes, AWS, Cloudflare, Terraform.
- Data technologies: SQL, PostgreSQL, MongoDB, Redis, Elasticsearch.
- Collaboration and delivery tools: Git/GitHub, CI systems, test runners, observability products, and API documentation tools.

The official catalog explicitly places these in Frameworks, Languages / Platforms, DevOps, and Databases, while placing capability-oriented items such as Computer Science, System Design, Design & Architecture, and Code Review under Computer Science or Best Practices: [catalog](https://roadmap.sh/roadmaps/). The distinction is useful for skill design: teach the invariant concept and decision principles first, then select one or more tools as concrete practice.

## Product and solo-business coverage gaps

The technical core does not cover the full product lifecycle. The current catalog also has Product Design, UX Design, Design System, Technical Writer, Developer Relations, and Product Manager tracks: [catalog](https://roadmap.sh/roadmaps/), [UX Design](https://roadmap.sh/ux-design), [Design System](https://roadmap.sh/design-system), [Technical Writer](https://roadmap.sh/technical-writer), [Developer Relations](https://roadmap.sh/devrel). These are represented by the added product, communication, analytics, and management principle skills.

Growth marketing, sales and monetization, customer success, privacy and legal risk, and finance and operations are needed for a solo business but are not represented as dedicated tracks in the current roadmap.sh catalog. They are therefore treated as separate business domains rather than inferred roadmap.sh categories.
