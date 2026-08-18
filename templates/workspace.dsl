workspace "PROJECT_NAME" "Brief description of the system and its purpose." {

    model {
        // ── People ────────────────────────────────────────────────────────────
        user  = person "User"  "Primary user of the system."
        admin = person "Admin" "System administrator."

        // ── External Systems ──────────────────────────────────────────────────
        // externalApi = softwareSystem "External API" "Third-party dependency." "External"

        // ── Primary System ────────────────────────────────────────────────────
        system = softwareSystem "PROJECT_NAME" "Brief description of what this system does." {
            !docs arc42
            !adrs adrs

            // ── Containers (deployable units) ─────────────────────────────────
            // TODO: Add your containers below. Examples:
            frontend   = container "Frontend"    "User interface."              "React / Vue"
            api        = container "API"         "Backend application API."     "FastAPI / Express"
            db         = container "Database"    "Persistent data store."       "PostgreSQL"     "Database"
        }

        // ── Relationships ─────────────────────────────────────────────────────
        user  -> system   "Uses"
        admin -> system   "Administers"

        user  -> frontend "Interacts with" "HTTPS"
        frontend -> api   "Makes API requests to" "HTTPS/JSON"
        api      -> db    "Reads and writes" "JDBC/SQL"

        // ── Deployment Environments ────────────────────────────────────────────
        deploymentEnvironment "Local" {
            deploymentNode "Developer Machine" "Local environment." "Docker Compose" {
                containerInstance frontend
                containerInstance api
                containerInstance db
            }
        }
    }

    views {
        // ── System Context ────────────────────────────────────────────────────
        systemContext system "SystemContext" "High-level overview of PROJECT_NAME." {
            include *
            autoLayout tb
        }

        // ── Container Diagram ─────────────────────────────────────────────────
        container system "ContainerDiagram" "Internal containers and their interactions." {
            include *
            autoLayout lr
        }

        // ── Deployment Diagram ────────────────────────────────────────────────
        deployment system "Local" "LocalDeployment" "Local Docker Compose deployment." {
            include *
            autoLayout lr
        }

        // ── Styles ────────────────────────────────────────────────────────────
        styles {
            element "Person" {
                background #08427b
                color #ffffff
                shape Person
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #205c94
                color #ffffff
            }
            relationship "Relationship" {
                routing Orthogonal
                thickness 2
                fontSize 14
                position 50
            }
        }
    }
}
