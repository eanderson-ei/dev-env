var viz;

function draw() {
    var config = {
        container_id: "viz",
        server_url: "bolt://localhost:7687",
        server_user: "neo4j",
        server_password: "incentives",
        labels: {
            "Project": {
                caption: "Project Name",
                size: "pagerank",
                community: "louvain"
            },
        },
        relationships: {
            "SHARES_TAGS": {
                caption: false,
                thickness: "count"
            }
        },
        initial_cypher: "MATCH (p:Project)-[s:SHARES_TAGS]->(p2:Project) RETURN p, p2, s ORDER BY s.count DESC LIMIT 100"
    };

    viz = new NeoVis.default(config);
    viz.render();
}

