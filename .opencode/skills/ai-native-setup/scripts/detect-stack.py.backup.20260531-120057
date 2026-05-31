#!/usr/bin/env python3
"""
AI-Native Tech Stack Detector
Automatically detects project type, stack, CI/CD, and test frameworks.
Outputs JSON for consumption by setup scripts.

Usage: python3 detect-stack.py [--json]
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional


class StackDetector:
    def __init__(self, project_root: str = "."):
        self.root = Path(project_root).resolve()
        self.results: Dict[str, Any] = {
            "project_type": "Unknown",
            "languages": [],
            "framework": None,
            "runtime": None,
            "package_manager": None,
            "test_frameworks": [],
            "ci_cd": None,
            "database": None,
            "orm": None,
            "docker": False,
            "monorepo": False,
            "monorepo_tool": None,
            "has_tests": False,
            "package_scripts": {},
            "build_commands": {},
            "env_files": [],
            "confidence": "low",
        }

    def detect(self) -> Dict[str, Any]:
        """Run all detection heuristics."""
        self._detect_languages()
        self._detect_nodejs()
        self._detect_python()
        self._detect_go()
        self._detect_rust()
        self._detect_java()
        self._detect_dotnet()
        self._detect_cicd()
        self._detect_database()
        self._detect_docker()
        self._detect_monorepo()
        self._detect_env_files()
        self._calculate_confidence()
        return self.results

    def _detect_languages(self):
        """Detect primary languages by file extension frequency."""
        extensions = {}
        for path in self.root.rglob("*"):
            if path.is_file() and "/node_modules/" not in str(path) and "/.git/" not in str(path):
                ext = path.suffix.lower()
                if ext in (".ts", ".tsx", ".js", ".jsx", ".py", ".go", ".rs", ".java", ".kt", ".cs", ".cpp", ".c", ".rb", ".php", ".swift", ".scala", ".clj"):
                    extensions[ext] = extensions.get(ext, 0) + 1

        # Sort by frequency
        sorted_exts = sorted(extensions.items(), key=lambda x: x[1], reverse=True)
        
        lang_map = {
            ".ts": "TypeScript", ".tsx": "TypeScript",
            ".js": "JavaScript", ".jsx": "JavaScript",
            ".py": "Python",
            ".go": "Go",
            ".rs": "Rust",
            ".java": "Java", ".kt": "Kotlin",
            ".cs": "C#", ".cpp": "C++", ".c": "C",
            ".rb": "Ruby",
            ".php": "PHP",
            ".swift": "Swift",
            ".scala": "Scala",
            ".clj": "Clojure"
        }

        seen = set()
        for ext, count in sorted_exts[:3]:
            lang = lang_map.get(ext)
            if lang and lang not in seen:
                seen.add(lang)
                self.results["languages"].append({"name": lang, "files": count})

    def _detect_nodejs(self):
        """Detect Node.js / TypeScript projects."""
        package_json = self.root / "package.json"
        if not package_json.exists():
            return

        self.results["project_type"] = "Node.js"
        self.results["package_manager"] = self._detect_node_package_manager()

        try:
            import json
            with open(package_json, "r", encoding="utf-8") as f:
                pkg = json.load(f)

            # Detect framework
            deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}
            frameworks = {
                "next": "Next.js", "react": "React", "vue": "Vue.js",
                "express": "Express", "fastify": "Fastify", "koa": "Koa",
                "nest": "NestJS", "angular": "Angular", "svelte": "Svelte",
                "remix": "Remix", "astro": "Astro", "nuxt": "Nuxt",
                "hono": "Hono", "elysia": "Elysia", "adonis": "AdonisJS"
            }
            for dep, fw_name in frameworks.items():
                if dep in deps:
                    self.results["framework"] = fw_name
                    break

            # Detect test frameworks
            test_frameworks = {
                "jest": "Jest", "vitest": "Vitest", "mocha": "Mocha",
                "cypress": "Cypress", "playwright": "Playwright",
                "supertest": "Supertest", "ava": "AVA", "tap": "Tap",
                "jasmine": "Jasmine", "karma": "Karma"
            }
            for dep, tf_name in test_frameworks.items():
                if dep in deps:
                    self.results["test_frameworks"].append(tf_name)

            # Detect runtime
            if self.root.glob("bun.lockb") or (self.root / "bunfig.toml").exists():
                self.results["runtime"] = "Bun"
            elif (self.root / ".nvmrc").exists():
                self.results["runtime"] = f"Node.js {self._read_file('.nvmrc').strip()}"
            elif pkg.get("engines", {}).get("node"):
                self.results["runtime"] = f"Node.js {pkg['engines']['node']}"
            else:
                self.results["runtime"] = "Node.js"

            # Extract scripts
            scripts = pkg.get("scripts", {})
            self.results["package_scripts"] = {
                k: v for k, v in scripts.items()
                if any(x in k for x in ["test", "build", "lint", "format", "dev", "start", "typecheck", "check"])
            }

            self.results["has_tests"] = bool(self.results["test_frameworks"])

        except Exception:
            pass

    def _detect_node_package_manager(self) -> str:
        if (self.root / "pnpm-lock.yaml").exists():
            return "pnpm"
        elif (self.root / "yarn.lock").exists():
            return "yarn"
        elif (self.root / "bun.lockb").exists() or (self.root / "bun.lock").exists():
            return "bun"
        elif (self.root / "package-lock.json").exists():
            return "npm"
        return "npm"

    def _detect_python(self):
        """Detect Python projects."""
        has_pyproject = (self.root / "pyproject.toml").exists()
        has_requirements = (self.root / "requirements.txt").exists()
        has_setup = (self.root / "setup.py").exists()
        has_pipfile = (self.root / "Pipfile").exists()

        if not any([has_pyproject, has_requirements, has_setup, has_pipfile]):
            return

        if self.results["project_type"] == "Unknown":
            self.results["project_type"] = "Python"

        # Package manager
        if has_pipfile:
            self.results["package_manager"] = "pipenv"
        elif (self.root / "poetry.lock").exists():
            self.results["package_manager"] = "poetry"
        elif has_pyproject:
            self.results["package_manager"] = "pip (pyproject)"
        else:
            self.results["package_manager"] = "pip"

        # Framework
        frameworks = {
            "django": "Django", "flask": "Flask", "fastapi": "FastAPI",
            "tornado": "Tornado", "bottle": "Bottle", "starlette": "Starlette",
            "quart": "Quart", "aiohttp": "AioHTTP", "litestar": "Litestar",
            "falcon": "Falcon", "turbogears": "TurboGears", "web2py": "Web2py",
            "cherrypy": "CherryPy", "sanic": "Sanic", "hug": "Hug"
        }

        for dep_file in ["requirements.txt", "Pipfile", "pyproject.toml"]:
            content = self._read_file(dep_file).lower()
            for dep, fw in frameworks.items():
                if dep in content:
                    self.results["framework"] = fw
                    break
            if self.results["framework"]:
                break

        # Test frameworks
        test_frameworks = {
            "pytest": "Pytest", "unittest": "unittest", "nose": "Nose",
            "behave": "Behave", "robot": "Robot Framework",
            "hypothesis": "Hypothesis", "doctest": "Doctest"
        }
        for dep_file in ["requirements.txt", "Pipfile", "pyproject.toml"]:
            content = self._read_file(dep_file).lower()
            for dep, tf in test_frameworks.items():
                if dep in content and tf not in self.results["test_frameworks"]:
                    self.results["test_frameworks"].append(tf)

        # Runtime
        if (self.root / ".python-version").exists():
            self.results["runtime"] = f"Python {self._read_file('.python-version').strip()}"
        elif has_pyproject:
            content = self._read_file("pyproject.toml")
            match = re.search(r'requires-python\s*=\s*["\']([^"\']+)["\']', content)
            if match:
                self.results["runtime"] = f"Python {match.group(1)}"
            else:
                self.results["runtime"] = "Python"
        else:
            self.results["runtime"] = "Python"

        self.results["has_tests"] = bool(self.results["test_frameworks"]) or bool(list(self.root.glob("**/test_*.py")))

    def _detect_go(self):
        """Detect Go projects."""
        go_mod = self.root / "go.mod"
        if not go_mod.exists():
            return

        if self.results["project_type"] == "Unknown":
            self.results["project_type"] = "Go"

        self.results["package_manager"] = "go modules"

        content = self._read_file("go.mod")

        # Go version
        match = re.search(r'^go\s+(\d+\.\d+)', content, re.MULTILINE)
        if match:
            self.results["runtime"] = f"Go {match.group(1)}"
        else:
            self.results["runtime"] = "Go"

        # Frameworks
        frameworks = {
            "gin": "Gin", "echo": "Echo", "fiber": "Fiber",
            "chi": "Chi", "mux": "Gorilla Mux", "httprouter": "HttpRouter",
            "fasthttp": "FastHTTP", "buffalo": "Buffalo", "beego": "Beego",
            "revel": "Revel", "iris": "Iris", "martini": "Martini"
        }
        for dep, fw in frameworks.items():
            if dep in content.lower():
                self.results["framework"] = fw
                break

        # Test frameworks (Go has built-in testing)
        self.results["test_frameworks"].append("go test")
        if "testify" in content.lower():
            self.results["test_frameworks"].append("testify")
        if "ginkgo" in content.lower():
            self.results["test_frameworks"].append("Ginkgo")
        if "goconvey" in content.lower():
            self.results["test_frameworks"].append("GoConvey")

        self.results["has_tests"] = True

    def _detect_rust(self):
        """Detect Rust projects."""
        cargo_toml = self.root / "Cargo.toml"
        if not cargo_toml.exists():
            return

        if self.results["project_type"] == "Unknown":
            self.results["project_type"] = "Rust"

        self.results["package_manager"] = "cargo"
        self.results["runtime"] = "Rust"

        content = self._read_file("Cargo.toml")

        frameworks = {
            "actix": "Actix-web", "axum": "Axum", "rocket": "Rocket",
            "tide": "Tide", "warp": "Warp", "iron": "Iron",
            "nickel": "Nickel", "poem": "Poem", "salvo": "Salvo",
            "thruster": "Thruster", "viz": "Viz", "ntex": "ntex"
        }
        for dep, fw in frameworks.items():
            if dep in content.lower():
                self.results["framework"] = fw
                break

        test_frameworks = {
            "tokio": "tokio-test", "mockall": "Mockall",
            "proptest": "Proptest", "quickcheck": "QuickCheck"
        }
        for dep, tf in test_frameworks.items():
            if dep in content.lower():
                self.results["test_frameworks"].append(tf)

        self.results["test_frameworks"].append("cargo test")
        self.results["has_tests"] = True

    def _detect_java(self):
        """Detect Java / Kotlin / JVM projects."""
        pom_xml = self.root / "pom.xml"
        build_gradle = self.root / "build.gradle"
        build_gradle_kts = self.root / "build.gradle.kts"

        if not any([pom_xml.exists(), build_gradle.exists(), build_gradle_kts.exists()]):
            return

        if self.results["project_type"] == "Unknown":
            self.results["project_type"] = "Java / JVM"

        # Package manager
        if pom_xml.exists():
            self.results["package_manager"] = "Maven"
            content = self._read_file("pom.xml")
        elif build_gradle_kts.exists():
            self.results["package_manager"] = "Gradle (Kotlin DSL)"
            content = self._read_file("build.gradle.kts")
        else:
            self.results["package_manager"] = "Gradle"
            content = self._read_file("build.gradle")

        # Runtime
        if "kotlin" in content.lower():
            self.results["runtime"] = "Kotlin / JVM"
        else:
            self.results["runtime"] = "Java / JVM"

        # Frameworks
        frameworks = {
            "spring-boot": "Spring Boot", "spring": "Spring",
            "quarkus": "Quarkus", "micronaut": "Micronaut",
            "jakarta": "Jakarta EE", "javaee": "Java EE",
            "vert.x": "Vert.x", "ktor": "Ktor", "play": "Play Framework",
            "dropwizard": "Dropwizard", "spark": "Spark Java",
            "ratpack": "Ratpack", "blade": "Blade"
        }
        for dep, fw in frameworks.items():
            if dep in content.lower():
                self.results["framework"] = fw
                break

        # Test frameworks
        test_frameworks = {
            "junit": "JUnit", "testng": "TestNG", "spock": "Spock",
            "mockito": "Mockito", "assertj": "AssertJ", "cucumber": "Cucumber JVM",
            "rest-assured": "REST Assured", "jacoco": "JaCoCo"
        }
        for dep, tf in test_frameworks.items():
            if dep in content.lower() and tf not in self.results["test_frameworks"]:
                self.results["test_frameworks"].append(tf)

        self.results["has_tests"] = bool(self.results["test_frameworks"])

    def _detect_dotnet(self):
        """Detect .NET projects."""
        csproj_files = list(self.root.glob("**/*.csproj"))
        fsproj_files = list(self.root.glob("**/*.fsproj"))
        vbproj_files = list(self.root.glob("**/*.vbproj"))
        sln_files = list(self.root.glob("*.sln"))

        if not any([csproj_files, fsproj_files, vbproj_files, sln_files]):
            return

        if self.results["project_type"] == "Unknown":
            self.results["project_type"] = ".NET"

        self.results["package_manager"] = "NuGet"

        if fsproj_files:
            self.results["runtime"] = "F# / .NET"
        elif vbproj_files:
            self.results["runtime"] = "VB.NET"
        else:
            self.results["runtime"] = "C# / .NET"

        # Read first csproj for framework info
        if csproj_files:
            content = csproj_files[0].read_text().lower()
            frameworks = {
                "asp.net": "ASP.NET Core", "aspnet": "ASP.NET Core",
                "blazor": "Blazor", "xamarin": "Xamarin",
                "maui": ".NET MAUI", "wpf": "WPF", "winforms": "WinForms"
            }
            for keyword, fw in frameworks.items():
                if keyword in content:
                    self.results["framework"] = fw
                    break

        self.results["test_frameworks"].append("xUnit / NUnit / MSTest")
        self.results["has_tests"] = True

    def _detect_cicd(self):
        """Detect CI/CD configuration."""
        cicd_files = {
            ".github/workflows": "GitHub Actions",
            ".gitlab-ci.yml": "GitLab CI",
            "azure-pipelines.yml": "Azure DevOps",
            "Jenkinsfile": "Jenkins",
            ".circleci/config.yml": "CircleCI",
            "buildkite.yml": "Buildkite",
            "appveyor.yml": "AppVeyor",
            "travis.yml": "Travis CI",
            "cloudbuild.yaml": "Google Cloud Build",
            "codefresh.yml": "Codefresh",
            "drone.yml": "Drone CI",
            "wercker.yml": "Wercker",
            "semaphore.yml": "Semaphore",
            "teamcity.yml": "TeamCity"
        }

        for path, name in cicd_files.items():
            full_path = self.root / path
            if full_path.exists():
                self.results["ci_cd"] = name
                return

    def _detect_database(self):
        """Detect database and ORM."""
        orm_map = {
            "prisma": ("Prisma", None),
            "typeorm": ("TypeORM", None),
            "sequelize": ("Sequelize", None),
            "mongoose": ("Mongoose", "MongoDB"),
            "mikro-orm": ("MikroORM", None),
            "drizzle-orm": ("Drizzle ORM", None),
            "sqlalchemy": ("SQLAlchemy", None),
            "django.db": ("Django ORM", None),
            "peewee": ("Peewee", None),
            "tortoise": ("Tortoise ORM", None),
            "gorm": ("GORM", None),
            "ent": ("Ent", None),
            "sqlx": ("sqlx", None),
            "diesel": ("Diesel", None),
            "sea-orm": ("SeaORM", None),
            "rusqlite": ("rusqlite", "SQLite"),
            "hibernate": ("Hibernate", None),
            "mybatis": ("MyBatis", None),
            "jpa": ("JPA", None),
            "entity framework": ("Entity Framework", None),
            "dapper": ("Dapper", None),
        }

        db_map = {
            "postgresql": "PostgreSQL", "postgres": "PostgreSQL",
            "mysql": "MySQL", "mariadb": "MariaDB",
            "mongodb": "MongoDB", "mongo": "MongoDB",
            "sqlite": "SQLite", "sqlite3": "SQLite",
            "redis": "Redis", "dynamodb": "DynamoDB",
            "cassandra": "Cassandra", "cockroachdb": "CockroachDB",
            "neo4j": "Neo4j", "elasticsearch": "Elasticsearch",
            "influxdb": "InfluxDB", "timescaledb": "TimescaleDB",
            "couchdb": "CouchDB", "firestore": "Firestore",
            "fauna": "FaunaDB", "supabase": "Supabase (PostgreSQL)"
        }

        # Check config files for DB references
        config_files = [
            "package.json", "requirements.txt", "Pipfile", "pyproject.toml",
            "go.mod", "Cargo.toml", "pom.xml", "build.gradle", "build.gradle.kts",
            "*.csproj", "appsettings.json", "docker-compose.yml", "Dockerfile",
            ".env.example", ".env", "prisma/schema.prisma", "ormconfig.json"
        ]

        all_content = ""
        for pattern in config_files:
            for file in self.root.glob(pattern):
                try:
                    all_content += file.read_text().lower() + "\n"
                except Exception:
                    pass

        # Detect ORM
        for keyword, (orm, default_db) in orm_map.items():
            if keyword in all_content:
                self.results["orm"] = orm
                if default_db:
                    self.results["database"] = default_db
                break

        # Detect DB
        for keyword, db_name in db_map.items():
            if keyword in all_content and not self.results["database"]:
                self.results["database"] = db_name
                break

        # Check docker-compose for DB services
        docker_compose = self.root / "docker-compose.yml"
        if docker_compose.exists():
            content = docker_compose.read_text().lower()
            for keyword, db_name in db_map.items():
                if keyword in content and not self.results["database"]:
                    self.results["database"] = db_name
                    break

    def _detect_docker(self):
        """Detect Docker usage."""
        self.results["docker"] = any([
            (self.root / "Dockerfile").exists(),
            (self.root / "docker-compose.yml").exists(),
            (self.root / "docker-compose.yaml").exists(),
            (self.root / ".dockerignore").exists(),
            len(list(self.root.glob("**/Dockerfile*"))) > 0
        ])

    def _detect_monorepo(self):
        """Detect monorepo structure."""
        tools = {
            "turborepo": ("turbo.json", "pnpm-workspace.yaml"),
            "nx": ("nx.json",),
            "rush": ("rush.json",),
            "lerna": ("lerna.json",),
            "bolt": ("bolt.json",),
            "yarn workspaces": ("package.json",)  # Check for workspaces field
        }

        for tool, files in tools.items():
            for f in files:
                path = self.root / f
                if path.exists():
                    if tool == "yarn workspaces":
                        content = self._read_file("package.json")
                        if '"workspaces"' in content:
                            self.results["monorepo"] = True
                            self.results["monorepo_tool"] = "yarn workspaces"
                            return
                    else:
                        self.results["monorepo"] = True
                        self.results["monorepo_tool"] = tool
                        return

        # Check for pnpm workspace
        if (self.root / "pnpm-workspace.yaml").exists():
            self.results["monorepo"] = True
            self.results["monorepo_tool"] = "pnpm workspaces"

    def _detect_env_files(self):
        """Detect environment configuration files."""
        env_files = [".env.example", ".env.sample", ".env.template", ".env.local"]
        for f in env_files:
            if (self.root / f).exists():
                self.results["env_files"].append(f)

    def _calculate_confidence(self):
        """Calculate confidence score based on detection signals."""
        score = 0
        if self.results["project_type"] != "Unknown":
            score += 3
        if self.results["framework"]:
            score += 2
        if self.results["runtime"]:
            score += 1
        if self.results["test_frameworks"]:
            score += 1
        if self.results["ci_cd"]:
            score += 1
        if self.results["database"]:
            score += 1

        if score >= 7:
            self.results["confidence"] = "high"
        elif score >= 4:
            self.results["confidence"] = "medium"
        else:
            self.results["confidence"] = "low"

    def _read_file(self, relative_path: str) -> str:
        """Read a file from project root."""
        path = self.root / relative_path
        if path.exists():
            try:
                return path.read_text()
            except Exception:
                return ""
        return ""


def main():
    detector = StackDetector()
    results = detector.detect()

    if "--json" in sys.argv:
        print(json.dumps(results, indent=2))
    else:
        print(f"Project Type: {results['project_type']}")
        print(f"Languages: {', '.join(l['name'] for l in results['languages'])}")
        print(f"Framework: {results['framework'] or 'Not detected'}")
        print(f"Runtime: {results['runtime'] or 'Not detected'}")
        print(f"Package Manager: {results['package_manager'] or 'Not detected'}")
        print(f"Test Frameworks: {', '.join(results['test_frameworks']) or 'Not detected'}")
        print(f"CI/CD: {results['ci_cd'] or 'Not detected'}")
        print(f"Database: {results['database'] or 'Not detected'}")
        print(f"ORM: {results['orm'] or 'Not detected'}")
        print(f"Docker: {'Yes' if results['docker'] else 'No'}")
        print(f"Monorepo: {'Yes (' + results['monorepo_tool'] + ')' if results['monorepo'] else 'No'}")
        print(f"Confidence: {results['confidence']}")


if __name__ == "__main__":
    main()
