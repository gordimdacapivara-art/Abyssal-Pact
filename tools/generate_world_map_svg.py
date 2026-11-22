"""
Generator for the Official Visual World Map of ABYSSAL PACT.
Produces world_map.svg using Dark Fantasy Medieval Cartography aesthetics.
Accurately maps the 4 continents, all 40 regions, Mar da Cicatriz,
Hell Forge dimensional cartouche, pictorial relief, and sidebar legend.
"""

import json
import math
import os

def load_cartography_data():
    with open("WORLD_MAP_DATA.json", "r", encoding="utf-8") as f:
        return json.load(f)

def build_svg():
    data = load_cartography_data()
    regions = data["regions"]
    continents = data["continents"]

    # Dimensions
    CANVAS_W = 3200
    CANVAS_H = 2200

    MAP_X0 = 100
    MAP_Y0 = 200
    MAP_W = 2360
    MAP_H = 1840

    def to_px(nx, ny):
        return round(MAP_X0 + nx * MAP_W, 1), round(MAP_Y0 + ny * MAP_H, 1)

    svg_parts = []

    # SVG Root Header
    svg_parts.append(f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {CANVAS_W} {CANVAS_H}" width="{CANVAS_W}" height="{CANVAS_H}">''')

    # Definitions
    svg_parts.append('''
  <defs>
    <!-- Dark Fantasy Parchment Gradients -->
    <radialGradient id="parchment-base" cx="50%" cy="50%" r="70%">
      <stop offset="0%" stop-color="#2a201c"/>
      <stop offset="45%" stop-color="#1f1815"/>
      <stop offset="80%" stop-color="#16110f"/>
      <stop offset="100%" stop-color="#0d0908"/>
    </radialGradient>

    <radialGradient id="vignette" cx="50%" cy="50%" r="65%">
      <stop offset="60%" stop-color="#000000" stop-opacity="0"/>
      <stop offset="90%" stop-color="#080605" stop-opacity="0.6"/>
      <stop offset="100%" stop-color="#020101" stop-opacity="0.95"/>
    </radialGradient>

    <!-- Ocean Gradients -->
    <radialGradient id="mar-da-cicatriz-vortex" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#090d12"/>
      <stop offset="25%" stop-color="#111720"/>
      <stop offset="60%" stop-color="#18222d"/>
      <stop offset="90%" stop-color="#1e2936"/>
      <stop offset="100%" stop-color="#253242"/>
    </radialGradient>

    <!-- Continents Fill Gradients -->
    <linearGradient id="grad-veyrath" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#362923"/>
      <stop offset="50%" stop-color="#2d221e"/>
      <stop offset="100%" stop-color="#221916"/>
    </linearGradient>

    <linearGradient id="grad-sylvaran" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1d2b1f"/>
      <stop offset="50%" stop-color="#243627"/>
      <stop offset="100%" stop-color="#18241a"/>
    </linearGradient>

    <linearGradient id="grad-khar-duum" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#3b2b1b"/>
      <stop offset="50%" stop-color="#322417"/>
      <stop offset="100%" stop-color="#241910"/>
    </linearGradient>

    <linearGradient id="grad-nhal-kora" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1e2c38"/>
      <stop offset="50%" stop-color="#273847"/>
      <stop offset="100%" stop-color="#17222b"/>
    </linearGradient>

    <!-- Hell Forge Dimensional Portal Gradient -->
    <radialGradient id="grad-hell-forge" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#ffe6a3"/>
      <stop offset="18%" stop-color="#ff7b2b"/>
      <stop offset="42%" stop-color="#b81b1b"/>
      <stop offset="70%" stop-color="#4a0d0d"/>
      <stop offset="95%" stop-color="#1f0505"/>
      <stop offset="100%" stop-color="#0a0202"/>
    </radialGradient>

    <!-- Metallic Gold/Bronze for Banners and Badges -->
    <linearGradient id="gold-banner" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#f5e1a4"/>
      <stop offset="30%" stop-color="#d4af37"/>
      <stop offset="70%" stop-color="#aa821d"/>
      <stop offset="100%" stop-color="#694e0d"/>
    </linearGradient>

    <linearGradient id="panel-bg" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#1f1815"/>
      <stop offset="100%" stop-color="#140f0d"/>
    </linearGradient>

    <!-- Drop Shadows -->
    <filter id="shadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="3" dy="4" stdDeviation="4" flood-color="#000000" flood-opacity="0.8"/>
    </filter>

    <filter id="glow-gold" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="3" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>
  </defs>
''')

    # 1. Background Parchment & Ocean Base
    svg_parts.append(f'''
  <!-- CANVAS BACKGROUND -->
  <rect x="0" y="0" width="{CANVAS_W}" height="{CANVAS_H}" fill="url(#parchment-base)"/>
  <rect x="{MAP_X0}" y="{MAP_Y0}" width="{MAP_W}" height="{MAP_H}" fill="url(#mar-da-cicatriz-vortex)" stroke="#524131" stroke-width="3"/>
''')

    # 2. Rhumb Lines / Graticule across Mar da Cicatriz
    cx_px, cy_px = to_px(0.50, 0.50)
    svg_parts.append('  <!-- RHUMB LINES & NAUTICAL GRATICULE -->')
    svg_parts.append(f'  <g stroke="#8c734b" stroke-opacity="0.18" stroke-width="1.2">')
    for angle in range(0, 360, 15):
        rad = math.radians(angle)
        x2 = cx_px + 1400 * math.cos(rad)
        y2 = cy_px + 1400 * math.sin(rad)
        svg_parts.append(f'    <line x1="{cx_px}" y1="{cy_px}" x2="{x2:.1f}" y2="{y2:.1f}"/>')
    # Concentric distance rings
    for r in [220, 440, 680, 950]:
        svg_parts.append(f'    <circle cx="{cx_px}" cy="{cy_px}" r="{r}" fill="none" stroke-dasharray="8,8"/>')
    svg_parts.append('  </g>')

    # 3. Nautical Wave Lines in Ocean
    svg_parts.append('  <!-- OCEAN WAVES & CURRENT RIPPLES -->')
    svg_parts.append('  <g stroke="#415369" stroke-opacity="0.3" stroke-width="1.2" fill="none">')
    wave_points = [
        (1200, 1020), (1360, 1060), (1280, 1220), (1180, 1150),
        (1400, 1180), (1100, 1080), (1450, 980), (1050, 1250)
    ]
    for wx, wy in wave_points:
        svg_parts.append(f'    <path d="M {wx-30} {wy} Q {wx-15} {wy-8} {wx} {wy} Q {wx+15} {wy+8} {wx+30} {wy}"/>')
        svg_parts.append(f'    <path d="M {wx-25} {wy+12} Q {wx-10} {wy+4} {wx+5} {wy+12} Q {wx+20} {wy+20} {wx+35} {wy+12}"/>')
    svg_parts.append('  </g>')

    # 4. Continental Landmasses & Regional Polygons
    cont_colors = {
        "CONT-01": {"fill": "url(#grad-veyrath)", "stroke": "#c85a2b", "accent": "#8a3a1f"},
        "CONT-02": {"fill": "url(#grad-sylvaran)", "stroke": "#4ec98b", "accent": "#2f7a55"},
        "CONT-03": {"fill": "url(#grad-khar-duum)", "stroke": "#d6a638", "accent": "#997321"},
        "CONT-04": {"fill": "url(#grad-nhal-kora)", "stroke": "#6ec5e8", "accent": "#3a7a99"},
    }

    svg_parts.append('  <!-- 40 REGIONS POLYGONS -->')
    for r_id, r in regions.items():
        c_id = r["continent_id"]
        cfg = cont_colors[c_id]
        poly = r["cartographic_position"]["polygon_vertices"]
        pts_str = " ".join([f"{to_px(vx, vy)[0]},{to_px(vx, vy)[1]}" for vx, vy in poly])

        # Polygon shape
        svg_parts.append(f'    <!-- {r_id}: {r["name"]} -->')
        svg_parts.append(f'    <polygon id="{r_id}" points="{pts_str}" fill="{cfg["fill"]}" stroke="{cfg["stroke"]}" stroke-width="2.5" stroke-linejoin="round" opacity="0.95" filter="url(#shadow)"/>')

        # Coastal buffer ripple / hachure outline
        svg_parts.append(f'    <polygon points="{pts_str}" fill="none" stroke="{cfg["accent"]}" stroke-width="6" stroke-opacity="0.25" stroke-linejoin="round"/>')

    # 5. Pictorial Terrain Features (Mountains, Trees, Dunes, Calderas, Ice)
    svg_parts.append('  <!-- PICTORIAL TERRAIN SYMBOLS -->')
    for r_id, r in regions.items():
        cx, cy = to_px(r["cartographic_position"]["normalized_center"][0], r["cartographic_position"]["normalized_center"][1])
        biome = r["biome"]
        c_id = r["continent_id"]

        # Mountains
        if biome in ["obsidian_peaks", "basalt_peaks", "burnt_canyon", "misty_ridge", "dry_canyon", "canyon_labyrinth", "ghostly_cliffs", "damned_fjord"]:
            # Draw pictorial mountain cones
            svg_parts.append(f'    <g id="mountains_{r_id}" stroke="#1a120e" stroke-width="1.8" fill="#523f35">')
            for dx, dy, h in [(-25, 10, 35), (0, -5, 45), (25, 15, 30)]:
                mx, my = cx + dx, cy + dy
                svg_parts.append(f'      <polygon points="{mx},{my-h} {mx-h*0.7:.1f},{my} {mx+h*0.7:.1f},{my}"/>')
                svg_parts.append(f'      <polygon points="{mx},{my-h} {mx},{my} {mx+h*0.7:.1f},{my}" fill="#2e221d"/>') # Shadow
            svg_parts.append('    </g>')

        # Caldera / Magma
        elif biome in ["caldera_edge", "magma_gorge", "sulfur_crags", "deepfire_gorge"]:
            svg_parts.append(f'    <g id="volcano_{r_id}" stroke="#1a0a05" stroke-width="2">')
            svg_parts.append(f'      <ellipse cx="{cx}" cy="{cy+5}" rx="32" ry="16" fill="#3a1e16"/>')
            svg_parts.append(f'      <ellipse cx="{cx}" cy="{cy+5}" rx="20" ry="10" fill="#e04e1b"/>')
            svg_parts.append(f'      <circle cx="{cx}" cy="{cy+5}" r="8" fill="#ffd13b"/>')
            # Smoke plume
            svg_parts.append(f'      <path d="M {cx-5} {cy-5} Q {cx-15} {cy-25} {cx-5} {cy-40} Q {cx+10} {cy-55} {cx} {cy-70}" fill="none" stroke="#6b5b54" stroke-width="4" stroke-linecap="round" opacity="0.6"/>')
            svg_parts.append('    </g>')

        # Primeval Forest & Canopy
        elif biome in ["whispering_woods", "ancient_roots", "black_willows", "shadow_jungle", "abyssal_heart", "rune_glade"]:
            svg_parts.append(f'    <g id="forest_{r_id}" stroke="#0f1a11" stroke-width="1.4" fill="#2d4731">')
            for dx, dy, r_size in [(-22, 10, 16), (0, -8, 20), (22, 12, 16)]:
                tx, ty = cx + dx, cy + dy
                svg_parts.append(f'      <circle cx="{tx}" cy="{ty}" r="{r_size}"/>')
                svg_parts.append(f'      <circle cx="{tx+4}" cy="{ty-3}" r="{r_size*0.7:.1f}" fill="#3f6144" stroke="none"/>')
                svg_parts.append(f'      <line x1="{tx}" y1="{ty+r_size}" x2="{tx}" y2="{ty+r_size+10}" stroke="#1a120e" stroke-width="2.5"/>')
            svg_parts.append('    </g>')

        # Deserts & Dunes
        elif biome in ["soot_desert", "black_sand_dunes", "silent_waste", "salt_flats", "sunscorched_plateau"]:
            svg_parts.append(f'    <g id="dunes_{r_id}" stroke="#785933" stroke-width="2" fill="none">')
            for dy in [-15, 0, 15]:
                svg_parts.append(f'      <path d="M {cx-35} {cy+dy} Q {cx-15} {cy+dy-10} {cx} {cy+dy} Q {cx+20} {cy+dy+10} {cx+35} {cy+dy}"/>')
            svg_parts.append('    </g>')

        # Glaciers & Ice Peaks
        elif biome in ["frozen_expanse", "abyssal_end", "oceanic_trench", "cold_coast"]:
            svg_parts.append(f'    <g id="glacier_{r_id}" stroke="#173245" stroke-width="1.6" fill="#88d2f2">')
            for dx, dy, h in [(-22, 10, 32), (4, -6, 42), (26, 12, 28)]:
                ix, iy = cx + dx, cy + dy
                svg_parts.append(f'      <polygon points="{ix},{iy-h} {ix-h*0.5:.1f},{iy} {ix+h*0.5:.1f},{iy}"/>')
                svg_parts.append(f'      <polygon points="{ix},{iy-h} {ix},{iy} {ix+h*0.5:.1f},{iy}" fill="#4081a8"/>')
            svg_parts.append('    </g>')

    # 6. Maritime Nautical Routes Across Mar da Cicatriz
    svg_parts.append('  <!-- MARITIME NAUTICAL LANES -->')
    svg_parts.append('  <g stroke="#d4af37" stroke-width="2.2" stroke-dasharray="10,6" opacity="0.8" fill="none">')
    # Ports: REG-001 (Veyrath), REG-011 (Sylvaran), REG-021 (Khar-Duum), REG-031 (Nhal'Kora)
    p_001 = to_px(regions["REG-001"]["cartographic_position"]["normalized_center"][0], regions["REG-001"]["cartographic_position"]["normalized_center"][1])
    p_011 = to_px(regions["REG-011"]["cartographic_position"]["normalized_center"][0], regions["REG-011"]["cartographic_position"]["normalized_center"][1])
    p_021 = to_px(regions["REG-021"]["cartographic_position"]["normalized_center"][0], regions["REG-021"]["cartographic_position"]["normalized_center"][1])
    p_031 = to_px(regions["REG-031"]["cartographic_position"]["normalized_center"][0], regions["REG-031"]["cartographic_position"]["normalized_center"][1])
    p_002 = to_px(regions["REG-002"]["cartographic_position"]["normalized_center"][0], regions["REG-002"]["cartographic_position"]["normalized_center"][1])

    # Routes
    svg_parts.append(f'    <path d="M {p_001[0]} {p_001[1]} Q {cx_px} {cy_px-180} {p_011[0]} {p_011[1]}"/>') # North Strait
    svg_parts.append(f'    <path d="M {p_001[0]} {p_001[1]} Q {cx_px-180} {cy_px} {p_021[0]} {p_021[1]}"/>') # West Channel
    svg_parts.append(f'    <path d="M {p_011[0]} {p_011[1]} Q {cx_px+180} {cy_px} {p_031[0]} {p_031[1]}"/>') # East Crossing
    svg_parts.append(f'    <path d="M {p_021[0]} {p_021[1]} Q {cx_px} {cy_px+180} {p_031[0]} {p_031[1]}"/>') # South Strait
    svg_parts.append(f'    <path d="M {p_002[0]} {p_002[1]} Q {cx_px} {cy_px} {p_031[0]} {p_031[1]}"/>')     # Deep Scar Cross
    svg_parts.append('  </g>')

    # 7. Mar da Cicatriz Central Vortex & Sea Monster Illustration
    svg_parts.append(f'''
  <!-- MAR DA CICATRIZ CENTER LABEL & VORTEX -->
  <g transform="translate({cx_px}, {cy_px})" filter="url(#shadow)">
    <!-- Vortex Rings -->
    <path d="M -80 0 A 80 40 0 1 0 80 0 A 60 30 0 1 0 -60 0 A 40 20 0 1 0 40 0 A 20 10 0 1 0 0 0" fill="none" stroke="#2a3d4f" stroke-width="2.5" stroke-linecap="round"/>
    
    <!-- Monster Silhouette (Leviatã do Abismo) -->
    <path d="M -120 -50 Q -100 -75 -70 -60 Q -40 -70 -20 -45 Q -5 -60 20 -40 Q 50 -60 80 -35 Q 110 -55 130 -30 Q 110 -15 80 -25 Q 50 -10 20 -25 Q -10 -10 -40 -20 Q -80 -10 -120 -50 Z" fill="#0d141c" stroke="#31485e" stroke-width="1.5"/>
    
    <!-- Title Banner -->
    <rect x="-180" y="55" width="360" height="36" rx="6" fill="#131b24" stroke="#8c734b" stroke-width="1.8"/>
    <text x="0" y="78" text-anchor="middle" font-family="'Cinzel', 'Trajan Pro', 'Georgia', serif" font-size="16" font-weight="bold" fill="#e8d5b5" letter-spacing="3">MAR DA CICATRIZ</text>
    <text x="0" y="105" text-anchor="middle" font-family="'Georgia', serif" font-size="11" font-style="italic" fill="#8c734b">Oceano Central &amp; Vórtice Abissal</text>
  </g>
''')

    # 8. Region Badges, Numbers & Labels for ALL 40 REGIONS
    svg_parts.append('  <!-- 40 REGION NUMBERED BADGES & NAMES -->')
    badge_colors = {
        "CONT-01": {"fill": "#802b12", "stroke": "#f08e56", "text": "#ffffff"},
        "CONT-02": {"fill": "#1b5e2b", "stroke": "#72e096", "text": "#ffffff"},
        "CONT-03": {"fill": "#875c12", "stroke": "#f5c862", "text": "#ffffff"},
        "CONT-04": {"fill": "#174e75", "stroke": "#7ed2f7", "text": "#ffffff"},
    }

    for r_id, r in regions.items():
        num_str = r_id.split("-")[1]
        cx, cy = to_px(r["cartographic_position"]["normalized_center"][0], r["cartographic_position"]["normalized_center"][1])
        c_id = r["continent_id"]
        cfg = badge_colors[c_id]
        name = r["name"]

        # If name is long, break into lines or position carefully
        short_name = name
        if len(name) > 22:
            words = name.split(" ")
            mid = len(words) // 2
            line1 = " ".join(words[:mid])
            line2 = " ".join(words[mid:])
        else:
            line1 = name
            line2 = ""

        svg_parts.append(f'''
    <!-- Badge for {r_id} -->
    <g transform="translate({cx}, {cy})" filter="url(#shadow)">
      <!-- Numbered Shield -->
      <circle cx="0" cy="0" r="17" fill="{cfg['fill']}" stroke="{cfg['stroke']}" stroke-width="2.5"/>
      <circle cx="0" cy="0" r="13" fill="none" stroke="{cfg['stroke']}" stroke-width="0.8" stroke-dasharray="2,2"/>
      <text x="0" y="5" text-anchor="middle" font-family="'Trajan Pro', 'Georgia', serif" font-size="12" font-weight="bold" fill="{cfg['text']}">{num_str}</text>

      <!-- Region Name Banner -->
      <rect x="-85" y="24" width="170" height="20" rx="3" fill="#15100d" fill-opacity="0.88" stroke="#66503b" stroke-width="1"/>
      <text x="0" y="38" text-anchor="middle" font-family="'Cinzel', 'Georgia', serif" font-size="9.5" font-weight="bold" fill="#f0dfc8" letter-spacing="0.5">{line1}</text>
''')
        if line2:
            svg_parts.append(f'''
      <rect x="-85" y="45" width="170" height="16" rx="3" fill="#15100d" fill-opacity="0.88" stroke="#66503b" stroke-width="0.8"/>
      <text x="0" y="57" text-anchor="middle" font-family="'Cinzel', 'Georgia', serif" font-size="8.5" font-weight="bold" fill="#f0dfc8" letter-spacing="0.5">{line2}</text>
''')
        # Structure icon: city / capital
        if r.get("capital_settlement"):
            svg_parts.append(f'''
      <!-- City marker -->
      <rect x="-6" y="-28" width="12" height="10" fill="#d4af37" stroke="#110d0a" stroke-width="1.2"/>
      <polygon points="-6,-28 0,-35 6,-28" fill="#a12519" stroke="#110d0a" stroke-width="1"/>
''')
        svg_parts.append('    </g>')

    # 9. Grand Continent Title Banners
    svg_parts.append('  <!-- CONTINENT TITLE BANNERS -->')
    cont_banners = [
        ("VEYRATH", "IMPÉRIO VULCÂNICO • REGIÕES 01 A 10", 0.25, 0.08, "#c85a2b"),
        ("SYLVARAN", "FLORESTA PRIMORDIAL & ILHAS SUSPENSAS • REGIÕES 11 A 20", 0.75, 0.08, "#4ec98b"),
        ("KHAR-DUUM", "CÂNIOS, AREIAS NEGRAS & CIDADELAS • REGIÕES 21 A 30", 0.25, 0.96, "#d6a638"),
        ("NHAL'KORA", "LITORAL GLACIAL, FIORDES & FOSSAS • REGIÕES 31 A 40", 0.75, 0.96, "#6ec5e8"),
    ]
    for title, subtitle, nx, ny, border_color in cont_banners:
        bx, by = to_px(nx, ny)
        svg_parts.append(f'''
    <g transform="translate({bx}, {by})" filter="url(#shadow)">
      <path d="M -180 -18 L 180 -18 L 195 0 L 180 18 L -180 18 L -195 0 Z" fill="#1a120e" stroke="{border_color}" stroke-width="2.2"/>
      <text x="0" y="4" text-anchor="middle" font-family="'Trajan Pro', 'Cinzel', 'Georgia', serif" font-size="18" font-weight="bold" fill="#f5e1a4" letter-spacing="5">{title}</text>
      <text x="0" y="28" text-anchor="middle" font-family="'Georgia', serif" font-size="8.5" font-weight="bold" fill="{border_color}" letter-spacing="1.5">{subtitle}</text>
    </g>
''')

    # 10. HELL FORGE DIMENSIONAL MEDALLION (Special non-physical dimension indicator)
    svg_parts.append(f'''
  <!-- HELL FORGE DIMENSIONAL MEDALLION (OUTSIDE CONTINENTS) -->
  <g transform="translate(1280, 95)" filter="url(#shadow)">
    <!-- Astral / Dimension Frame -->
    <circle cx="0" cy="0" r="58" fill="#140606" stroke="#d4af37" stroke-width="3"/>
    <circle cx="0" cy="0" r="48" fill="url(#grad-hell-forge)"/>
    <circle cx="0" cy="0" r="48" fill="none" stroke="#ffe082" stroke-width="1.5" stroke-dasharray="4,4"/>

    <!-- Anvil & Runic Flame Silhouette -->
    <path d="M -22 -8 L 22 -8 L 16 6 L 6 6 L 10 18 L -10 18 L -6 6 L -16 6 Z" fill="#2b0d0a" stroke="#ffd54f" stroke-width="1.5"/>
    <path d="M -8 -8 Q 0 -30 8 -8 Q 0 -18 -8 -8 Z" fill="#ffeb3b" stroke="#ff5722" stroke-width="1"/>

    <!-- Inscription Ribbon -->
    <rect x="-190" y="55" width="380" height="26" rx="4" fill="#1c0707" stroke="#df9b32" stroke-width="1.5"/>
    <text x="0" y="72" text-anchor="middle" font-family="'Trajan Pro', 'Georgia', serif" font-size="12" font-weight="bold" fill="#ffe082" letter-spacing="2">HELL FORGE</text>
    <text x="0" y="94" text-anchor="middle" font-family="'Georgia', serif" font-size="9" font-style="italic" fill="#ffab91">DIMENSÃO INDEPENDENTE — NEXUS PLANAR DE RESSURGIMENTO</text>
    <text x="0" y="106" text-anchor="middle" font-family="'Georgia', serif" font-size="7.5" fill="#c4907a">(Acessível estritamente por portais arcanos • Não pertence ao plano físico)</text>
  </g>
''')

    # 11. Grand Map Header / Banner
    svg_parts.append(f'''
  <!-- GRAND TITLE BANNER -->
  <g transform="translate(560, 90)" filter="url(#shadow)">
    <rect x="-420" y="-45" width="840" height="85" rx="6" fill="#16110f" stroke="#d4af37" stroke-width="2.5"/>
    <rect x="-412" y="-37" width="824" height="69" rx="4" fill="none" stroke="#6e5233" stroke-width="1"/>
    <text x="0" y="-8" text-anchor="middle" font-family="'Trajan Pro', 'Cinzel Decorative', 'Georgia', serif" font-size="28" font-weight="bold" fill="url(#gold-banner)" letter-spacing="6">ABYSSAL PACT</text>
    <text x="0" y="18" text-anchor="middle" font-family="'Trajan Pro', 'Georgia', serif" font-size="12" font-weight="bold" fill="#e8d5b5" letter-spacing="3">CHARTA TERRARUM ET PROFUNDI • MAPA-MÚNDI OFICIAL</text>
  </g>
''')

    # 12. Compass Rose (Rosa dos Ventos) in Mar da Cicatriz / SW corner
    compass_x = MAP_X0 + 260
    compass_y = MAP_Y0 + 1600
    svg_parts.append(f'''
  <!-- COMPASS ROSE (ROSA DOS VENTOS) -->
  <g transform="translate({compass_x}, {compass_y})" filter="url(#shadow)">
    <circle cx="0" cy="0" r="75" fill="#1a1412" stroke="#8c734b" stroke-width="2"/>
    <circle cx="0" cy="0" r="68" fill="none" stroke="#d4af37" stroke-width="1.2" stroke-dasharray="3,3"/>
    
    <!-- 8 Points -->
    <!-- North -->
    <polygon points="0,-72 8,-15 0,0" fill="#d4af37"/>
    <polygon points="0,-72 -8,-15 0,0" fill="#8c734b"/>
    <!-- South -->
    <polygon points="0,72 8,15 0,0" fill="#8c734b"/>
    <polygon points="0,72 -8,15 0,0" fill="#523f2b"/>
    <!-- East -->
    <polygon points="72,0 15,8 0,0" fill="#d4af37"/>
    <polygon points="72,0 15,-8 0,0" fill="#8c734b"/>
    <!-- West -->
    <polygon points="-72,0 -15,8 0,0" fill="#8c734b"/>
    <polygon points="-72,0 -15,-8 0,0" fill="#523f2b"/>

    <!-- Intermediate Points -->
    <polygon points="46,-46 12,-4 0,0" fill="#aa821d"/>
    <polygon points="-46,-46 -12,-4 0,0" fill="#694e0d"/>
    <polygon points="46,46 12,4 0,0" fill="#694e0d"/>
    <polygon points="-46,46 -12,4 0,0" fill="#423008"/>

    <!-- Central Boss -->
    <circle cx="0" cy="0" r="10" fill="#f5e1a4" stroke="#423008" stroke-width="1.5"/>
    <circle cx="0" cy="0" r="4" fill="#a12519"/>

    <!-- Cardinal Labels -->
    <text x="0" y="-80" text-anchor="middle" font-family="'Trajan Pro', 'Georgia', serif" font-size="14" font-weight="bold" fill="#f5e1a4">N</text>
    <text x="0" y="93" text-anchor="middle" font-family="'Trajan Pro', 'Georgia', serif" font-size="14" font-weight="bold" fill="#c4aa76">S</text>
    <text x="85" y="5" text-anchor="middle" font-family="'Trajan Pro', 'Georgia', serif" font-size="14" font-weight="bold" fill="#c4aa76">L</text>
    <text x="-85" y="5" text-anchor="middle" font-family="'Trajan Pro', 'Georgia', serif" font-size="14" font-weight="bold" fill="#c4aa76">O</text>
  </g>
''')

    # 13. Illustrative Graphic Scale Bar
    scale_x = MAP_X0 + 720
    scale_y = MAP_Y0 + 1780
    svg_parts.append(f'''
  <!-- GRAPHIC SCALE BAR -->
  <g transform="translate({scale_x}, {scale_y})" filter="url(#shadow)">
    <rect x="-160" y="-18" width="320" height="36" rx="4" fill="#140f0d" stroke="#8c734b" stroke-width="1.5"/>
    <!-- Scale Segments -->
    <rect x="-140" y="-5" width="70" height="10" fill="#d4af37" stroke="#140f0d" stroke-width="1"/>
    <rect x="-70" y="-5" width="70" height="10" fill="#140f0d" stroke="#d4af37" stroke-width="1"/>
    <rect x="0" y="-5" width="70" height="10" fill="#d4af37" stroke="#140f0d" stroke-width="1"/>
    <rect x="70" y="-5" width="70" height="10" fill="#140f0d" stroke="#d4af37" stroke-width="1"/>
    
    <!-- Scale Labels -->
    <text x="-140" y="-9" text-anchor="middle" font-family="'Georgia', serif" font-size="9" fill="#e8d5b5">0</text>
    <text x="-70" y="-9" text-anchor="middle" font-family="'Georgia', serif" font-size="9" fill="#e8d5b5">50</text>
    <text x="0" y="-9" text-anchor="middle" font-family="'Georgia', serif" font-size="9" fill="#e8d5b5">100</text>
    <text x="70" y="-9" text-anchor="middle" font-family="'Georgia', serif" font-size="9" fill="#e8d5b5">150</text>
    <text x="140" y="-9" text-anchor="middle" font-family="'Georgia', serif" font-size="9" fill="#e8d5b5">200 Léguas</text>
    <text x="0" y="14" text-anchor="middle" font-family="'Georgia', serif" font-size="7.5" font-style="italic" fill="#8c734b">Escala Cartográfica Oficial (1 Légua = 2,5 km mundiais)</text>
  </g>
''')

    # 14. RIGHT-HAND COMPREHENSIVE SIDEBAR LEGEND (ALL 40 REGIONS DETAILED)
    LEGEND_X = 2500
    LEGEND_Y = 180
    LEGEND_W = 640
    LEGEND_H = 1940

    svg_parts.append(f'''
  <!-- SIDEBAR COMPREHENSIVE LEGEND (ALL 40 REGIONS) -->
  <g transform="translate({LEGEND_X}, {LEGEND_Y})" filter="url(#shadow)">
    <!-- Legend Outer Box -->
    <rect x="0" y="0" width="{LEGEND_W}" height="{LEGEND_H}" rx="8" fill="url(#panel-bg)" stroke="#8c734b" stroke-width="2.5"/>
    <rect x="8" y="8" width="{LEGEND_W-16}" height="{LEGEND_H-16}" rx="6" fill="none" stroke="#524131" stroke-width="1.2"/>

    <!-- Legend Header -->
    <rect x="18" y="16" width="{LEGEND_W-36}" height="42" rx="4" fill="#241913" stroke="#d4af37" stroke-width="1.5"/>
    <text x="{LEGEND_W/2}" y="42" text-anchor="middle" font-family="'Trajan Pro', 'Georgia', serif" font-size="16" font-weight="bold" fill="url(#gold-banner)" letter-spacing="3">ÍNDICE DAS 40 REGIÕES</text>

    <!-- Symbology Guide -->
    <g transform="translate(25, 72)" font-family="'Georgia', serif" font-size="9" fill="#e8d5b5">
      <rect x="0" y="0" width="8" height="8" fill="#d4af37"/>
      <text x="14" y="8">Capital / Cidade Segura</text>

      <circle cx="150" cy="4" r="4" fill="#a12519" stroke="#ffffff" stroke-width="0.8"/>
      <text x="160" y="8">Masmorra Regional</text>

      <polygon points="290,0 295,8 285,8" fill="#e04e1b"/>
      <text x="300" y="8">Arena de Chefe</text>

      <circle cx="430" cy="4" r="5" fill="#9c27b0"/>
      <text x="440" y="8">Portal Dimensional</text>
    </g>
''')

    # Now render the 4 sections of 10 regions each
    cont_sections = [
        ("CONT-01", "VEYRATH (01 a 10) — NOROESTE", "#c85a2b", 100),
        ("CONT-02", "SYLVARAN (11 a 20) — NORDESTE", "#4ec98b", 550),
        ("CONT-03", "KHAR-DUUM (21 a 30) — SUDOESTE", "#d6a638", 1000),
        ("CONT-04", "NHAL'KORA (31 a 40) — SUDESTE", "#6ec5e8", 1450),
    ]

    for c_id, sec_title, sec_color, sec_y in cont_sections:
        c_regs = [r for r_id, r in regions.items() if r["continent_id"] == c_id]
        
        svg_parts.append(f'''
    <!-- Section {c_id} -->
    <g transform="translate(20, {sec_y})">
      <!-- Section Banner -->
      <rect x="0" y="0" width="{LEGEND_W-40}" height="24" rx="3" fill="#1b120e" stroke="{sec_color}" stroke-width="1.4"/>
      <text x="12" y="16" font-family="'Trajan Pro', 'Georgia', serif" font-size="11" font-weight="bold" fill="{sec_color}" letter-spacing="1.5">{sec_title}</text>
''')
        row_y = 32
        for r in c_regs:
            num = r["id"].split("-")[1]
            r_name = r["name"]
            biome = r["biome"].replace("_", " ")
            lvl = f"Nv {r['level_range'][0]}–{r['level_range'][1]}"
            city = r["capital_settlement"]
            dung = r["dungeon"]
            boss = f"[{r['associated_boss']}]" if r["associated_boss"] else ""

            svg_parts.append(f'''
      <!-- Row {r["id"]} -->
      <g transform="translate(6, {row_y})">
        <!-- Badge -->
        <circle cx="12" cy="11" r="10" fill="{sec_color}" stroke="#140f0d" stroke-width="1.2"/>
        <text x="12" y="15" text-anchor="middle" font-family="'Trajan Pro', 'Georgia', serif" font-size="9" font-weight="bold" fill="#ffffff">{num}</text>
        
        <!-- Region Name & Level -->
        <text x="28" y="10" font-family="'Cinzel', 'Georgia', serif" font-size="10" font-weight="bold" fill="#f5e6d3">{r_name}</text>
        <text x="290" y="10" font-family="'Georgia', serif" font-size="8.5" fill="{sec_color}">{lvl}</text>
        <text x="350" y="10" font-family="'Georgia', serif" font-size="8.5" font-weight="bold" fill="#e04e1b">{boss}</text>

        <!-- Subline: City, Dungeon, Biome -->
        <text x="28" y="24" font-family="'Georgia', serif" font-size="8" fill="#9e8a76">🏙️ {city}  •  🏰 {dung}  •  🌿 {biome}</text>
        
        <!-- Divider -->
        <line x1="10" y1="31" x2="{LEGEND_W-60}" y2="31" stroke="#382920" stroke-width="0.8"/>
      </g>
''')
            row_y += 38

        svg_parts.append('    </g>')

    # Cartographer Seal & Inscription at bottom of sidebar
    svg_parts.append(f'''
    <!-- Cartographer Signature & Seal -->
    <g transform="translate(20, 1860)">
      <rect x="0" y="0" width="{LEGEND_W-40}" height="60" rx="4" fill="#140e0c" stroke="#8c734b" stroke-width="1.2"/>
      <text x="16" y="22" font-family="'Trajan Pro', 'Georgia', serif" font-size="10" font-weight="bold" fill="#d4af37">AUTORIA CARTOGRÁFICA CANÔNICA</text>
      <text x="16" y="38" font-family="'Georgia', serif" font-size="8.5" fill="#baa288">Exarado pelo Cartógrafo Principal de ABYSSAL PACT.</text>
      <text x="16" y="50" font-family="'Georgia', serif" font-size="7.5" fill="#7a6855">Coordenadas Normalizadas [0.0, 1.0] • 40 Regiões • Mar da Cicatriz • Hell Forge</text>
    </g>
  </g>
''')

    # 15. Vignette Overlay & Border Frame
    svg_parts.append(f'''
  <!-- VIGNETTE OVERLAY -->
  <rect x="0" y="0" width="{CANVAS_W}" height="{CANVAS_H}" fill="url(#vignette)" pointer-events="none"/>

  <!-- TRIPLE CARTOGRAPHIC BORDER FRAME -->
  <rect x="15" y="15" width="{CANVAS_W-30}" height="{CANVAS_H-30}" rx="10" fill="none" stroke="#8c734b" stroke-width="3"/>
  <rect x="23" y="23" width="{CANVAS_W-46}" height="{CANVAS_H-46}" rx="8" fill="none" stroke="#d4af37" stroke-width="1.2" stroke-dasharray="6,4"/>
  <rect x="30" y="30" width="{CANVAS_W-60}" height="{CANVAS_H-60}" rx="6" fill="none" stroke="#524131" stroke-width="2"/>

  <!-- CORNER ORNAMENTS -->
  <g fill="#d4af37" stroke="#1a1412" stroke-width="1">
    <!-- Top-Left -->
    <polygon points="35,35 65,35 65,43 43,43 43,65 35,65"/>
    <circle cx="50" cy="50" r="5"/>
    <!-- Top-Right -->
    <polygon points="{CANVAS_W-35},35 {CANVAS_W-65},35 {CANVAS_W-65},43 {CANVAS_W-43},43 {CANVAS_W-43},65 {CANVAS_W-35},65"/>
    <circle cx="{CANVAS_W-50}" cy="50" r="5"/>
    <!-- Bottom-Left -->
    <polygon points="35,{CANVAS_H-35} 65,{CANVAS_H-35} 65,{CANVAS_H-43} 43,{CANVAS_H-43} 43,{CANVAS_H-65} 35,{CANVAS_H-65}"/>
    <circle cx="50" cy="{CANVAS_H-50}" r="5"/>
    <!-- Bottom-Right -->
    <polygon points="{CANVAS_W-35},{CANVAS_H-35} {CANVAS_W-65},{CANVAS_H-35} {CANVAS_W-65},{CANVAS_H-43} {CANVAS_W-43},{CANVAS_H-43} {CANVAS_W-43},{CANVAS_H-65} {CANVAS_W-35},{CANVAS_H-65}"/>
    <circle cx="{CANVAS_W-50}" cy="{CANVAS_H-50}" r="5"/>
  </g>
</svg>
''')

    full_svg = "\n".join(svg_parts)
    with open("world_map.svg", "w", encoding="utf-8") as f:
        f.write(full_svg)
    print(f"[OK] world_map.svg gerado com sucesso ({len(full_svg):,} bytes).")

if __name__ == "__main__":
    build_svg()
