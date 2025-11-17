(async function () {
    const width = 975;
    const height = 610;

    // Data & geometry sources
    // CDC diabetes/obesity by county (same data used in the Observable example)
    const DATA_URL =
      "https://gist.githubusercontent.com/mbostock/74a5eafd839597f6c66a1c1dcb6f499f/raw/1742edce177a3b6d059715d2e04fa1315f23c600/cdc-diabetes-obesity.csv";

    // US counties & states, already projected to a 975×610 Albers viewBox
    const TOPO_URL =
      "https://cdn.jsdelivr.net/npm/us-atlas@3/counties-albers-10m.json";

    // Bivariate color schemes (from the Joshua Stevens palettes)
    const schemes = [
      {
        name: "BuPu",
        colors: [
          "#e8e8e8",
          "#ace4e4",
          "#5ac8c8",
          "#dfb0d6",
          "#a5add3",
          "#5698b9",
          "#be64ac",
          "#8c62aa",
          "#3b4994",
        ],
      },

    ];

    // Pick one scheme (you can change the index 0–3)
    const colors = schemes[0].colors; // RdBu

    // Load geometry and data in parallel
    const [us, data] = await Promise.all([
      d3.json(TOPO_URL),
      d3.csv(DATA_URL, (d) => ({
        county: d.county, // 5-digit FIPS
        diabetes: +d.diabetes,
        obesity: +d.obesity,
      })),
    ]);

    const labels = ["low", "", "high"];
    const n = Math.floor(Math.sqrt(colors.length)); // 3 for a 3×3 grid

    // Quantile scales for each variable (0,1,2)
    const x = d3.scaleQuantile(
      data.map((d) => d.diabetes),
      d3.range(n)
    );
    const y = d3.scaleQuantile(
      data.map((d) => d.obesity),
      d3.range(n)
    );

    // Index data by county FIPS
    const index = new Map(data.map((d) => [d.county, d]));

    // TopoJSON is already projected to 975×610, so no projection is needed
    const path = d3.geoPath();

    function color(value) {
      if (!value) return "#ccc";
      const a = value.diabetes;
      const b = value.obesity;
      // diabetes quantile on one axis, obesity on the other
      return colors[y(b) + x(a) * n];
    }

    function formatValue(value) {
      if (!value) return "N/A";
      const a = value.diabetes;
      const b = value.obesity;
      const lx = labels[x(a)];
      const ly = labels[y(b)];
      const diabetesLabel = lx ? ` (${lx})` : "";
      const obesityLabel = ly ? ` (${ly})` : "";
      return `${a}% Diabetes${diabetesLabel}\n${b}% Obesity${obesityLabel}`;
    }

    const svg = d3
      .select("#chart")
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", [0, 0, width, height])
      .attr("style", "max-width: 100%; height: auto;");

    // Legend (3×3 rotated square with arrows)
    const legendGroup = svg
      .append("g")
      .attr("transform", "translate(870, 450)")
      .attr("font-size", 12);

    const k = 24; // cell size

    // Arrow marker for legend axes
    const defs = legendGroup.append("defs");
    defs
      .append("marker")
      .attr("id", "legend-arrow")
      .attr("viewBox", "0 0 10 6")
      .attr("refX", 6)
      .attr("refY", 3)
      .attr("markerWidth", 10)
      .attr("markerHeight", 10)
      .attr("orient", "auto")
      .append("path")
      .attr("d", "M0,0L9,3L0,6Z")
      .attr("fill", "black");

    const legend = legendGroup
      .append("g")
      .attr(
        "transform",
        `translate(${-((k * n) / 2)},${-((k * n) / 2)}) rotate(-45 ${
          (k * n) / 2
        },${(k * n) / 2})`
      );

    // 3×3 color grid
    legend
      .selectAll("rect")
      .data(d3.cross(d3.range(n), d3.range(n))) // [i, j]
      .join("rect")
      .attr("width", k)
      .attr("height", k)
      .attr("x", ([i, j]) => i * k)
      .attr("y", ([i, j]) => (n - 1 - j) * k)
      .attr("fill", ([i, j]) => colors[j * n + i])
      .append("title")
      .text(([i, j]) => {
        const diabetesLabel = labels[j]
          ? ` (${labels[j]})`
          : "";
        const obesityLabel = labels[i]
          ? ` (${labels[i]})`
          : "";
        return `Diabetes${diabetesLabel}\nObesity${obesityLabel}`;
      });

    // Legend axes
    legend
      .append("line")
      .attr("x1", 0)
      .attr("y1", n * k)
      .attr("x2", n * k)
      .attr("y2", n * k)
      .attr("stroke", "black")
      .attr("stroke-width", 1.5)
      .attr("marker-end", "url(#legend-arrow)");

    legend
      .append("line")
      .attr("x1", 0)
      .attr("y1", n * k)
      .attr("x2", 0)
      .attr("y2", 0)
      .attr("stroke", "black")
      .attr("stroke-width", 1.5)
      .attr("marker-end", "url(#legend-arrow)");

    // Axis labels
    legend
      .append("text")
      .attr("font-weight", "bold")
      .attr("dy", "0.71em")
      .attr("transform", `rotate(90) translate(${(n / 2) * k}, 6)`)
      .attr("text-anchor", "middle")
      .text("Diabetes");

    legend
      .append("text")
      .attr("font-weight", "bold")
      .attr("dy", "0.71em")
      .attr("transform", `translate(${(n / 2) * k}, ${n * k + 6})`)
      .attr("text-anchor", "middle")
      .text("Obesity");

    // State name lookup for tooltips
    const states = new Map(
      us.objects.states.geometries.map((d) => [d.id, d.properties])
    );

    // Draw counties
    svg
      .append("g")
      .selectAll("path")
      .data(topojson.feature(us, us.objects.counties).features)
      .join("path")
      .attr("fill", (d) => color(index.get(d.id)))
      .attr("d", path)
      .append("title")
      .text((d) => {
        const state = states.get(d.id.slice(0, 2));
        const label = state ? `${d.properties.name}, ${state.name}` : d.properties.name;
        const values = formatValue(index.get(d.id));
        return `${label}\n${values}`;
      });

    // Draw state borders
    svg
      .append("path")
      .datum(
        topojson.mesh(us, us.objects.states, (a, b) => a !== b)
      )
      .attr("fill", "none")
      .attr("stroke", "white")
      .attr("stroke-linejoin", "round")
      .attr("d", path);
  })();