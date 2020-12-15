if(!window.dash_clientside) {window.dash_clientside = {};}
window.dash_clientside.clientside = {
    draw: function draw(project) {
        var viz;
        var config = {
            container_id: "viz",
            server_url: "bolt://localhost:7687",
            server_user: "neo4j",
            server_password: "incentives",
            labels: {
                "Project": {
                    caption: "Project Name",
                    size: "pagerank",
                    community: "louvain",
                    font: {
                        face: "Gill Sans MT",
                        color: "#000000",
                        size: 12,
                    },
                    title_properties: [
                        "Project Name",
                        "Project Name - Local Language (if applicable)",
                        "project_number",
                        "Start Date",
                        "End Data",
                        "Reported Results",
                        "Transaction Type",
                        "Constant Amount",
                        "Current Amount",
                        "pagerank",
                        "louvain"
                    ],
                },
                hierarchical: true
            },
            relationships: {
                "SHARES_TAGS": {
                    caption: false,
                    thickness: "count"
                }
            },
            initial_cypher: "MATCH (p:Project {`Project Name`: '" + project + "'})-[s:SHARES_TAGS]->(p2:Project) RETURN p, p2, s ORDER BY s.count DESC LIMIT 7"
        };
    
        viz = new NeoVis.default(config);
        viz.render();
    }
}