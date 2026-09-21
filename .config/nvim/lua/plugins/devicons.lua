-- ┌────────────────────────────────────────────────────────────────┐
-- │   nvim-web-devicons — Neovide glyph compatibility                │
-- └────────────────────────────────────────────────────────────────┘
--
-- GENERATED from the installed font's cmap. Safe to hand-edit.
--
-- TWO problems, one file:
--
--  1. ASTRAL GLYPHS. Nerd Fonts puts the Material Design set in the
--     supplementary private use area (U+F0000+). The font HAS them, but
--     Neovide 0.15 on Windows only resolves glyphs from the BMP cmap
--     subtable, so every U+F0xxx icon draws as an empty box. Verified: this
--     font's (3,10) format-12 subtable contains them, its (3,1) format-4
--     subtable does not, and only the latter is reached.
--
--  2. MISSING GLYPHS. devicons tracks the newest Nerd Fonts release; the
--     installed patch is older and lacks 24 of its codepoints outright.
--
-- Neovide cannot fall back for either case: its built-in fallback chain ends
-- in the family "monospace", which does not exist on Windows, so the chain
-- fails to build. That same failure is the FontOptions error at startup.
--
-- Every replacement below is confirmed present in the BMP cmap of
--   %LOCALAPPDATA%/Microsoft/Windows/Fonts/JetBrainsMonoNerdFont-Regular.ttf

return {
  "nvim-tree/nvim-web-devicons",
  lazy = false,
  priority = 1000,

  opts = {
    override_by_extension = {
      ["3mf"]                        = { icon = "\u{F1B2}", color = "#888888", name = "3Mf" }, -- was U+F01A7
      Dockerfile                     = { icon = "\u{E7B0}", color = "#458EE6", name = "Dockerfile" }, -- was U+F0868
      R                              = { icon = "\u{E68A}", color = "#2266BA", name = "R" }, -- was U+F07D4
      asc                            = { icon = "\u{F084}", color = "#576D7F", name = "Asc" }, -- was U+F099D
      asmdef                         = { icon = "\u{E615}", color = "#407AAB", name = "Asmdef" }, -- was U+F0431
      ass                            = { icon = "\u{F0FD}", color = "#FFB713", name = "Ass" }, -- was U+F0A16
      bak                            = { icon = "\u{F0C7}", color = "#6D8086", name = "Bak" }, -- was U+F006F
      bib                            = { icon = "\u{E69B}", color = "#CBCB41", name = "Bib" }, -- was U+F125F
      blend                          = { icon = "\u{F1FC}", color = "#EA7600", name = "Blend" }, -- was U+F00AB
      blp                            = { icon = "\u{F1C5}", color = "#5796E2", name = "Blp" }, -- was U+F0EBE
      brep                           = { icon = "\u{F1B2}", color = "#839463", name = "Brep" }, -- was U+F0EEB
      cow                            = { icon = "\u{F15B}", color = "#965824", name = "Cow" }, -- was U+F019A
      cs                             = { icon = "\u{E648}", color = "#596706", name = "Cs" }, -- was U+F031B
      cshtml                         = { icon = "\u{E648}", color = "#512BD4", name = "Cshtml" }, -- was U+F1997
      csproj                         = { icon = "\u{E648}", color = "#512BD4", name = "Csproj" }, -- was U+F0AAE
      css                            = { icon = "\u{E749}", color = "#663399", name = "Css" }, -- was U+E6B8
      cue                            = { icon = "\u{F001}", color = "#ED95AE", name = "Cue" }, -- was U+F0CB9
      doc                            = { icon = "\u{F1C2}", color = "#185ABD", name = "Doc" }, -- was U+F022C
      dockerignore                   = { icon = "\u{E7B0}", color = "#458EE6", name = "Dockerignore" }, -- was U+F0868
      docx                           = { icon = "\u{F1C2}", color = "#185ABD", name = "Docx" }, -- was U+F022C
      dot                            = { icon = "\u{F1E0}", color = "#30638E", name = "Dot" }, -- was U+F1049
      dwg                            = { icon = "\u{F1B2}", color = "#839463", name = "Dwg" }, -- was U+F0EEB
      dxf                            = { icon = "\u{F1B2}", color = "#839463", name = "Dxf" }, -- was U+F0EEB
      f3d                            = { icon = "\u{F1B2}", color = "#839463", name = "F3D" }, -- was U+F0EEB
      f90                            = { icon = "\u{E61B}", color = "#734F96", name = "F90" }, -- was U+F121A
      fbx                            = { icon = "\u{F1B2}", color = "#888888", name = "Fbx" }, -- was U+F01A7
      fodg                           = { icon = "\u{F15B}", color = "#FFFB57", name = "Fodg" }, -- was U+F379
      fodp                           = { icon = "\u{F15B}", color = "#FE9C45", name = "Fodp" }, -- was U+F37A
      fods                           = { icon = "\u{F15B}", color = "#78FC4E", name = "Fods" }, -- was U+F378
      fodt                           = { icon = "\u{F15B}", color = "#2DCBFD", name = "Fodt" }, -- was U+F37C
      frag                           = { icon = "\u{F1FE}", color = "#5586A6", name = "Frag" }, -- was U+E855
      gcode                          = { icon = "\u{F1B2}", color = "#1471AD", name = "Gcode" }, -- was U+F042B
      geom                           = { icon = "\u{F1FE}", color = "#5586A6", name = "Geom" }, -- was U+E855
      glsl                           = { icon = "\u{F1FE}", color = "#5586A6", name = "Glsl" }, -- was U+E855
      gv                             = { icon = "\u{F1E0}", color = "#30638E", name = "Gv" }, -- was U+F1049
      huff                           = { icon = "\u{E624}", color = "#4242C7", name = "Huff" }, -- was U+F0858
      ifc                            = { icon = "\u{F1B2}", color = "#839463", name = "Ifc" }, -- was U+F0EEB
      ige                            = { icon = "\u{F1B2}", color = "#839463", name = "Ige" }, -- was U+F0EEB
      iges                           = { icon = "\u{F1B2}", color = "#839463", name = "Iges" }, -- was U+F0EEB
      igs                            = { icon = "\u{F1B2}", color = "#839463", name = "Igs" }, -- was U+F0EEB
      ipynb                          = { icon = "\u{E606}", color = "#F57D01", name = "Ipynb" }, -- was U+E80F
      kbx                            = { icon = "\u{F084}", color = "#737672", name = "Kbx" }, -- was U+F0BC4
      log                            = { icon = "\u{F18D}", color = "#DDDDDD", name = "Log" }, -- was U+F0331
      lrc                            = { icon = "\u{F0FD}", color = "#FFB713", name = "Lrc" }, -- was U+F0A16
      m3u                            = { icon = "\u{F001}", color = "#ED95AE", name = "M3U" }, -- was U+F0CB9
      m3u8                           = { icon = "\u{F001}", color = "#ED95AE", name = "M3U8" }, -- was U+F0CB9
      md5                            = { icon = "\u{F084}", color = "#8C86AF", name = "Md5" }, -- was U+F0565
      mint                           = { icon = "\u{F15B}", color = "#87C095", name = "Mint" }, -- was U+F032A
      norg                           = { icon = "\u{E609}", color = "#4878BE", name = "Norg" }, -- was U+E847
      obj                            = { icon = "\u{F1B2}", color = "#888888", name = "Obj" }, -- was U+F01A7
      odf                            = { icon = "\u{F15B}", color = "#FF5A96", name = "Odf" }, -- was U+F37B
      odg                            = { icon = "\u{F15B}", color = "#FFFB57", name = "Odg" }, -- was U+F379
      odin                           = { icon = "\u{E624}", color = "#3882D2", name = "Odin" }, -- was U+F07E2
      odp                            = { icon = "\u{F15B}", color = "#FE9C45", name = "Odp" }, -- was U+F37A
      ods                            = { icon = "\u{F15B}", color = "#78FC4E", name = "Ods" }, -- was U+F378
      odt                            = { icon = "\u{F15B}", color = "#2DCBFD", name = "Odt" }, -- was U+F37C
      pls                            = { icon = "\u{F001}", color = "#ED95AE", name = "Pls" }, -- was U+F0CB9
      ply                            = { icon = "\u{F1B2}", color = "#888888", name = "Ply" }, -- was U+F01A7
      ppt                            = { icon = "\u{F1C4}", color = "#CB4A32", name = "Ppt" }, -- was U+F0227
      pptx                           = { icon = "\u{F1C4}", color = "#CB4A32", name = "Pptx" }, -- was U+F0227
      ps1                            = { icon = "\u{E683}", color = "#4273CA", name = "Ps1" }, -- was U+F0A0A
      psd1                           = { icon = "\u{E683}", color = "#6975C4", name = "Psd1" }, -- was U+F0A0A
      psm1                           = { icon = "\u{E683}", color = "#6975C4", name = "Psm1" }, -- was U+F0A0A
      pub                            = { icon = "\u{F084}", color = "#E3C58E", name = "Pub" }, -- was U+F0DD6
      r                              = { icon = "\u{E68A}", color = "#2266BA", name = "R" }, -- was U+F07D4
      razor                          = { icon = "\u{E648}", color = "#512BD4", name = "Razor" }, -- was U+F1998
      rkt                            = { icon = "\u{E6B1}", color = "#9F1D20", name = "Rkt" }, -- was U+F0627
      rproj                          = { icon = "\u{E68A}", color = "#358A5B", name = "Rproj" }, -- was U+F05C6
      scm                            = { icon = "\u{E6B1}", color = "#EEEEEE", name = "Scm" }, -- was U+F0627
      sha1                           = { icon = "\u{F084}", color = "#8C86AF", name = "Sha1" }, -- was U+F0565
      sha224                         = { icon = "\u{F084}", color = "#8C86AF", name = "Sha224" }, -- was U+F0565
      sha256                         = { icon = "\u{F084}", color = "#8C86AF", name = "Sha256" }, -- was U+F0565
      sha384                         = { icon = "\u{F084}", color = "#8C86AF", name = "Sha384" }, -- was U+F0565
      sha512                         = { icon = "\u{F084}", color = "#8C86AF", name = "Sha512" }, -- was U+F0565
      sig                            = { icon = "\u{E6B1}", color = "#E37933", name = "Sig" }, -- was U+F0627
      signature                      = { icon = "\u{E6B1}", color = "#E37933", name = "Signature" }, -- was U+F0627
      skp                            = { icon = "\u{F1B2}", color = "#839463", name = "Skp" }, -- was U+F0EEB
      sldasm                         = { icon = "\u{F1B2}", color = "#839463", name = "Sldasm" }, -- was U+F0EEB
      sldprt                         = { icon = "\u{F1B2}", color = "#839463", name = "Sldprt" }, -- was U+F0EEB
      slvs                           = { icon = "\u{F1B2}", color = "#839463", name = "Slvs" }, -- was U+F0EEB
      sml                            = { icon = "\u{E6B1}", color = "#E37933", name = "Sml" }, -- was U+F0627
      srt                            = { icon = "\u{F0FD}", color = "#FFB713", name = "Srt" }, -- was U+F0A16
      ssa                            = { icon = "\u{F0FD}", color = "#FFB713", name = "Ssa" }, -- was U+F0A16
      ste                            = { icon = "\u{F1B2}", color = "#839463", name = "Ste" }, -- was U+F0EEB
      step                           = { icon = "\u{F1B2}", color = "#839463", name = "Step" }, -- was U+F0EEB
      stl                            = { icon = "\u{F1B2}", color = "#888888", name = "Stl" }, -- was U+F01A7
      ["stories.js"]                 = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesJs" }, -- was U+E8B3
      ["stories.jsx"]                = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesJsx" }, -- was U+E8B3
      ["stories.mjs"]                = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesMjs" }, -- was U+E8B3
      ["stories.svelte"]             = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesSvelte" }, -- was U+E8B3
      ["stories.ts"]                 = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesTs" }, -- was U+E8B3
      ["stories.tsx"]                = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesTsx" }, -- was U+E8B3
      ["stories.vue"]                = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesVue" }, -- was U+E8B3
      stp                            = { icon = "\u{F1B2}", color = "#839463", name = "Stp" }, -- was U+F0EEB
      sub                            = { icon = "\u{F0FD}", color = "#FFB713", name = "Sub" }, -- was U+F0A16
      sv                             = { icon = "\u{F2DB}", color = "#019833", name = "Sv" }, -- was U+F035B
      svg                            = { icon = "\u{F1C5}", color = "#FFB13B", name = "Svg" }, -- was U+F0721
      svgz                           = { icon = "\u{F1C5}", color = "#FFB13B", name = "Svgz" }, -- was U+F0721
      svh                            = { icon = "\u{F2DB}", color = "#019833", name = "Svh" }, -- was U+F035B
      tbc                            = { icon = "\u{E69F}", color = "#1E5CB3", name = "Tbc" }, -- was U+F06D3
      tcl                            = { icon = "\u{E69F}", color = "#1E5CB3", name = "Tcl" }, -- was U+F06D3
      txt                            = { icon = "\u{F15C}", color = "#89E051", name = "Txt" }, -- was U+F0219
      typ                            = { icon = "\u{F15B}", color = "#0DBCC0", name = "Typ" }, -- was U+F37F
      v                              = { icon = "\u{F2DB}", color = "#019833", name = "V" }, -- was U+F035B
      vala                           = { icon = "\u{E69B}", color = "#7B3DB9", name = "Vala" }, -- was U+E8D1
      vert                           = { icon = "\u{F1FE}", color = "#5586A6", name = "Vert" }, -- was U+E855
      vh                             = { icon = "\u{F2DB}", color = "#019833", name = "Vh" }, -- was U+F035B
      vhd                            = { icon = "\u{F2DB}", color = "#019833", name = "Vhd" }, -- was U+F035B
      vhdl                           = { icon = "\u{F2DB}", color = "#019833", name = "Vhdl" }, -- was U+F035B
      vi                             = { icon = "\u{E62B}", color = "#FEC60A", name = "Vi" }, -- was U+E81E
      webpack                        = { icon = "\u{E60B}", color = "#519ABA", name = "Webpack" }, -- was U+F072B
      wrl                            = { icon = "\u{F1B2}", color = "#888888", name = "Wrl" }, -- was U+F01A7
      wrz                            = { icon = "\u{F1B2}", color = "#888888", name = "Wrz" }, -- was U+F01A7
      xaml                           = { icon = "\u{F121}", color = "#512BD4", name = "Xaml" }, -- was U+F0673
      xls                            = { icon = "\u{F1C3}", color = "#207245", name = "Xls" }, -- was U+F021B
      xlsx                           = { icon = "\u{F1C3}", color = "#207245", name = "Xlsx" }, -- was U+F021B
      xml                            = { icon = "\u{F121}", color = "#E37933", name = "Xml" }, -- was U+F05C0
      xslt                           = { icon = "\u{F121}", color = "#33A9DC", name = "Xslt" }, -- was U+F05C0
      yaml                           = { icon = "\u{E615}", color = "#D70000", name = "Yaml" }, -- was U+E8EB
      yml                            = { icon = "\u{E615}", color = "#D70000", name = "Yml" }, -- was U+E8EB
    },

    override_by_filename = {
      [".codespellrc"]               = { icon = "\u{E615}", color = "#35DA60", name = "Codespellrc" }, -- was U+F04C6
      [".dockerignore"]              = { icon = "\u{E7B0}", color = "#458EE6", name = "Dockerignore" }, -- was U+F0868
      [".mailmap"]                   = { icon = "\u{E702}", color = "#F54D27", name = "Mailmap" }, -- was U+F02A2
      [".nanorc"]                    = { icon = "\u{E615}", color = "#440077", name = "Nanorc" }, -- was U+E838
      [".nuxtrc"]                    = { icon = "\u{E627}", color = "#00C58E", name = "Nuxtrc" }, -- was U+F1106
      [".pnpmfile.cjs"]              = { icon = "\u{E71E}", color = "#F9AD02", name = "PnpmfileCjs" }, -- was U+E865
      [".pre-commit-config.yaml"]    = { icon = "\u{E729}", color = "#F8B424", name = "PreCommitConfigYaml" }, -- was U+F06E2
      [".srcinfo"]                   = { icon = "\u{F303}", color = "#0F94D2", name = "Srcinfo" }, -- was U+F08C7
      ["bitbucket-pipelines.yml"]    = { icon = "\u{E703}", color = "#2684FF", name = "BitbucketPipelinesYml" }, -- was U+F00A8
      checkhealth                    = { icon = "\u{F0F1}", color = "#75B4FB", name = "Checkhealth" }, -- was U+F04D9
      ["commitlint.config.js"]       = { icon = "\u{E729}", color = "#2B9689", name = "CommitlintConfigJs" }, -- was U+F0718
      ["commitlint.config.ts"]       = { icon = "\u{E729}", color = "#2B9689", name = "CommitlintConfigTs" }, -- was U+F0718
      ["compose.yaml"]               = { icon = "\u{E7B0}", color = "#458EE6", name = "ComposeYaml" }, -- was U+F0868
      ["compose.yml"]                = { icon = "\u{E7B0}", color = "#458EE6", name = "ComposeYml" }, -- was U+F0868
      containerfile                  = { icon = "\u{E7B0}", color = "#458EE6", name = "Containerfile" }, -- was U+F0868
      ["docker-compose.yaml"]        = { icon = "\u{E7B0}", color = "#458EE6", name = "DockerComposeYaml" }, -- was U+F0868
      ["docker-compose.yml"]         = { icon = "\u{E7B0}", color = "#458EE6", name = "DockerComposeYml" }, -- was U+F0868
      dockerfile                     = { icon = "\u{E7B0}", color = "#458EE6", name = "Dockerfile" }, -- was U+F0868
      ["i18n.config.js"]             = { icon = "\u{F0AC}", color = "#7986CB", name = "I18NConfigJs" }, -- was U+F05CA
      ["i18n.config.ts"]             = { icon = "\u{F0AC}", color = "#7986CB", name = "I18NConfigTs" }, -- was U+F05CA
      ["next.config.cjs"]            = { icon = "\u{E781}", color = "#FFFFFF", name = "NextConfigCjs" }, -- was U+E83E
      ["next.config.js"]             = { icon = "\u{E781}", color = "#FFFFFF", name = "NextConfigJs" }, -- was U+E83E
      ["next.config.ts"]             = { icon = "\u{E781}", color = "#FFFFFF", name = "NextConfigTs" }, -- was U+E83E
      ["nuxt.config.cjs"]            = { icon = "\u{E627}", color = "#00C58E", name = "NuxtConfigCjs" }, -- was U+F1106
      ["nuxt.config.js"]             = { icon = "\u{E627}", color = "#00C58E", name = "NuxtConfigJs" }, -- was U+F1106
      ["nuxt.config.mjs"]            = { icon = "\u{E627}", color = "#00C58E", name = "NuxtConfigMjs" }, -- was U+F1106
      ["nuxt.config.ts"]             = { icon = "\u{E627}", color = "#00C58E", name = "NuxtConfigTs" }, -- was U+F1106
      ["pnpm-lock.yaml"]             = { icon = "\u{E71E}", color = "#F9AD02", name = "PnpmLockYaml" }, -- was U+E865
      ["pnpm-workspace.yaml"]        = { icon = "\u{E71E}", color = "#F9AD02", name = "PnpmWorkspaceYaml" }, -- was U+E865
      readme                         = { icon = "\u{F02D}", color = "#EDEDED", name = "Readme" }, -- was U+F00BA
      ["readme.md"]                  = { icon = "\u{F02D}", color = "#EDEDED", name = "ReadmeMd" }, -- was U+F00BA
      ["robots.txt"]                 = { icon = "\u{F1B0}", color = "#5D7096", name = "RobotsTxt" }, -- was U+F06A9
      security                       = { icon = "\u{F132}", color = "#BEC4C9", name = "Security" }, -- was U+F0483
      ["security.md"]                = { icon = "\u{F132}", color = "#BEC4C9", name = "SecurityMd" }, -- was U+F0483
      ["tailwind.config.js"]         = { icon = "\u{E60B}", color = "#20C2E3", name = "TailwindConfigJs" }, -- was U+F13FF
      ["tailwind.config.mjs"]        = { icon = "\u{E60B}", color = "#20C2E3", name = "TailwindConfigMjs" }, -- was U+F13FF
      ["tailwind.config.ts"]         = { icon = "\u{E60B}", color = "#20C2E3", name = "TailwindConfigTs" }, -- was U+F13FF
      ["vercel.json"]                = { icon = "\u{E615}", color = "#FFFFFF", name = "VercelJson" }, -- was U+E8D3
      ["vite.config.cjs"]            = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigCjs" }, -- was U+E8D7
      ["vite.config.cts"]            = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigCts" }, -- was U+E8D7
      ["vite.config.js"]             = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigJs" }, -- was U+E8D7
      ["vite.config.mjs"]            = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigMjs" }, -- was U+E8D7
      ["vite.config.mts"]            = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigMts" }, -- was U+E8D7
      ["vite.config.ts"]             = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigTs" }, -- was U+E8D7
      ["vitest.config.cjs"]          = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigCjs" }, -- was U+E8D9
      ["vitest.config.cts"]          = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigCts" }, -- was U+E8D9
      ["vitest.config.js"]           = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigJs" }, -- was U+E8D9
      ["vitest.config.mjs"]          = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigMjs" }, -- was U+E8D9
      ["vitest.config.mts"]          = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigMts" }, -- was U+E8D9
      ["vitest.config.ts"]           = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigTs" }, -- was U+E8D9
      vlcrc                          = { icon = "\u{F03D}", color = "#EE7A00", name = "Vlcrc" }, -- was U+F057C
      webpack                        = { icon = "\u{E60B}", color = "#519ABA", name = "Webpack" }, -- was U+F072B
    },

    override = {
      [".codespellrc"]               = { icon = "\u{E615}", color = "#35DA60", name = "Codespellrc" }, -- was U+F04C6
      [".dockerignore"]              = { icon = "\u{E7B0}", color = "#458EE6", name = "Dockerignore" }, -- was U+F0868
      [".mailmap"]                   = { icon = "\u{E702}", color = "#F54D27", name = "Mailmap" }, -- was U+F02A2
      [".nanorc"]                    = { icon = "\u{E615}", color = "#440077", name = "Nanorc" }, -- was U+E838
      [".nuxtrc"]                    = { icon = "\u{E627}", color = "#00C58E", name = "Nuxtrc" }, -- was U+F1106
      [".pnpmfile.cjs"]              = { icon = "\u{E71E}", color = "#F9AD02", name = "PnpmfileCjs" }, -- was U+E865
      [".pre-commit-config.yaml"]    = { icon = "\u{E729}", color = "#F8B424", name = "PreCommitConfigYaml" }, -- was U+F06E2
      [".srcinfo"]                   = { icon = "\u{F303}", color = "#0F94D2", name = "Srcinfo" }, -- was U+F08C7
      ["3mf"]                        = { icon = "\u{F1B2}", color = "#888888", name = "3Mf" }, -- was U+F01A7
      Dockerfile                     = { icon = "\u{E7B0}", color = "#458EE6", name = "Dockerfile" }, -- was U+F0868
      R                              = { icon = "\u{E68A}", color = "#2266BA", name = "R" }, -- was U+F07D4
      arch                           = { icon = "\u{F303}", color = "#0F94D2", name = "Arch" }, -- was U+F08C7
      asc                            = { icon = "\u{F084}", color = "#576D7F", name = "Asc" }, -- was U+F099D
      asmdef                         = { icon = "\u{E615}", color = "#407AAB", name = "Asmdef" }, -- was U+F0431
      ass                            = { icon = "\u{F0FD}", color = "#FFB713", name = "Ass" }, -- was U+F0A16
      bak                            = { icon = "\u{F0C7}", color = "#6D8086", name = "Bak" }, -- was U+F006F
      bib                            = { icon = "\u{E69B}", color = "#CBCB41", name = "Bib" }, -- was U+F125F
      ["bitbucket-pipelines.yml"]    = { icon = "\u{E703}", color = "#2684FF", name = "BitbucketPipelinesYml" }, -- was U+F00A8
      blend                          = { icon = "\u{F1FC}", color = "#EA7600", name = "Blend" }, -- was U+F00AB
      blp                            = { icon = "\u{F1C5}", color = "#5796E2", name = "Blp" }, -- was U+F0EBE
      brep                           = { icon = "\u{F1B2}", color = "#839463", name = "Brep" }, -- was U+F0EEB
      checkhealth                    = { icon = "\u{F0F1}", color = "#75B4FB", name = "Checkhealth" }, -- was U+F04D9
      ["commitlint.config.js"]       = { icon = "\u{E729}", color = "#2B9689", name = "CommitlintConfigJs" }, -- was U+F0718
      ["commitlint.config.ts"]       = { icon = "\u{E729}", color = "#2B9689", name = "CommitlintConfigTs" }, -- was U+F0718
      ["compose.yaml"]               = { icon = "\u{E7B0}", color = "#458EE6", name = "ComposeYaml" }, -- was U+F0868
      ["compose.yml"]                = { icon = "\u{E7B0}", color = "#458EE6", name = "ComposeYml" }, -- was U+F0868
      containerfile                  = { icon = "\u{E7B0}", color = "#458EE6", name = "Containerfile" }, -- was U+F0868
      cow                            = { icon = "\u{F15B}", color = "#965824", name = "Cow" }, -- was U+F019A
      cs                             = { icon = "\u{E648}", color = "#596706", name = "Cs" }, -- was U+F031B
      cshtml                         = { icon = "\u{E648}", color = "#512BD4", name = "Cshtml" }, -- was U+F1997
      csproj                         = { icon = "\u{E648}", color = "#512BD4", name = "Csproj" }, -- was U+F0AAE
      css                            = { icon = "\u{E749}", color = "#663399", name = "Css" }, -- was U+E6B8
      cue                            = { icon = "\u{F001}", color = "#ED95AE", name = "Cue" }, -- was U+F0CB9
      doc                            = { icon = "\u{F1C2}", color = "#185ABD", name = "Doc" }, -- was U+F022C
      ["docker-compose.yaml"]        = { icon = "\u{E7B0}", color = "#458EE6", name = "DockerComposeYaml" }, -- was U+F0868
      ["docker-compose.yml"]         = { icon = "\u{E7B0}", color = "#458EE6", name = "DockerComposeYml" }, -- was U+F0868
      dockerfile                     = { icon = "\u{E7B0}", color = "#458EE6", name = "Dockerfile" }, -- was U+F0868
      dockerignore                   = { icon = "\u{E7B0}", color = "#458EE6", name = "Dockerignore" }, -- was U+F0868
      docx                           = { icon = "\u{F1C2}", color = "#185ABD", name = "Docx" }, -- was U+F022C
      dot                            = { icon = "\u{F1E0}", color = "#30638E", name = "Dot" }, -- was U+F1049
      dwg                            = { icon = "\u{F1B2}", color = "#839463", name = "Dwg" }, -- was U+F0EEB
      dxf                            = { icon = "\u{F1B2}", color = "#839463", name = "Dxf" }, -- was U+F0EEB
      f3d                            = { icon = "\u{F1B2}", color = "#839463", name = "F3D" }, -- was U+F0EEB
      f90                            = { icon = "\u{E61B}", color = "#734F96", name = "F90" }, -- was U+F121A
      fbx                            = { icon = "\u{F1B2}", color = "#888888", name = "Fbx" }, -- was U+F01A7
      fodg                           = { icon = "\u{F15B}", color = "#FFFB57", name = "Fodg" }, -- was U+F379
      fodp                           = { icon = "\u{F15B}", color = "#FE9C45", name = "Fodp" }, -- was U+F37A
      fods                           = { icon = "\u{F15B}", color = "#78FC4E", name = "Fods" }, -- was U+F378
      fodt                           = { icon = "\u{F15B}", color = "#2DCBFD", name = "Fodt" }, -- was U+F37C
      frag                           = { icon = "\u{F1FE}", color = "#5586A6", name = "Frag" }, -- was U+E855
      gcode                          = { icon = "\u{F1B2}", color = "#1471AD", name = "Gcode" }, -- was U+F042B
      gentoo                         = { icon = "\u{F30D}", color = "#B1ABCE", name = "Gentoo" }, -- was U+F08E8
      geom                           = { icon = "\u{F1FE}", color = "#5586A6", name = "Geom" }, -- was U+E855
      glsl                           = { icon = "\u{F1FE}", color = "#5586A6", name = "Glsl" }, -- was U+E855
      gv                             = { icon = "\u{F1E0}", color = "#30638E", name = "Gv" }, -- was U+F1049
      huff                           = { icon = "\u{E624}", color = "#4242C7", name = "Huff" }, -- was U+F0858
      ["i18n.config.js"]             = { icon = "\u{F0AC}", color = "#7986CB", name = "I18NConfigJs" }, -- was U+F05CA
      ["i18n.config.ts"]             = { icon = "\u{F0AC}", color = "#7986CB", name = "I18NConfigTs" }, -- was U+F05CA
      ifc                            = { icon = "\u{F1B2}", color = "#839463", name = "Ifc" }, -- was U+F0EEB
      ige                            = { icon = "\u{F1B2}", color = "#839463", name = "Ige" }, -- was U+F0EEB
      iges                           = { icon = "\u{F1B2}", color = "#839463", name = "Iges" }, -- was U+F0EEB
      igs                            = { icon = "\u{F1B2}", color = "#839463", name = "Igs" }, -- was U+F0EEB
      ipynb                          = { icon = "\u{E606}", color = "#F57D01", name = "Ipynb" }, -- was U+E80F
      kbx                            = { icon = "\u{F084}", color = "#737672", name = "Kbx" }, -- was U+F0BC4
      leap                           = { icon = "\u{F17C}", color = "#FBC75D", name = "Leap" }, -- was U+F37E
      log                            = { icon = "\u{F18D}", color = "#DDDDDD", name = "Log" }, -- was U+F0331
      lrc                            = { icon = "\u{F0FD}", color = "#FFB713", name = "Lrc" }, -- was U+F0A16
      m3u                            = { icon = "\u{F001}", color = "#ED95AE", name = "M3U" }, -- was U+F0CB9
      m3u8                           = { icon = "\u{F001}", color = "#ED95AE", name = "M3U8" }, -- was U+F0CB9
      md5                            = { icon = "\u{F084}", color = "#8C86AF", name = "Md5" }, -- was U+F0565
      mint                           = { icon = "\u{F15B}", color = "#87C095", name = "Mint" }, -- was U+F032A
      ["next.config.cjs"]            = { icon = "\u{E781}", color = "#FFFFFF", name = "NextConfigCjs" }, -- was U+E83E
      ["next.config.js"]             = { icon = "\u{E781}", color = "#FFFFFF", name = "NextConfigJs" }, -- was U+E83E
      ["next.config.ts"]             = { icon = "\u{E781}", color = "#FFFFFF", name = "NextConfigTs" }, -- was U+E83E
      nobara                         = { icon = "\u{F17C}", color = "#FFFFFF", name = "Nobara" }, -- was U+F380
      norg                           = { icon = "\u{E609}", color = "#4878BE", name = "Norg" }, -- was U+E847
      ["nuxt.config.cjs"]            = { icon = "\u{E627}", color = "#00C58E", name = "NuxtConfigCjs" }, -- was U+F1106
      ["nuxt.config.js"]             = { icon = "\u{E627}", color = "#00C58E", name = "NuxtConfigJs" }, -- was U+F1106
      ["nuxt.config.mjs"]            = { icon = "\u{E627}", color = "#00C58E", name = "NuxtConfigMjs" }, -- was U+F1106
      ["nuxt.config.ts"]             = { icon = "\u{E627}", color = "#00C58E", name = "NuxtConfigTs" }, -- was U+F1106
      obj                            = { icon = "\u{F1B2}", color = "#888888", name = "Obj" }, -- was U+F01A7
      odf                            = { icon = "\u{F15B}", color = "#FF5A96", name = "Odf" }, -- was U+F37B
      odg                            = { icon = "\u{F15B}", color = "#FFFB57", name = "Odg" }, -- was U+F379
      odin                           = { icon = "\u{E624}", color = "#3882D2", name = "Odin" }, -- was U+F07E2
      odp                            = { icon = "\u{F15B}", color = "#FE9C45", name = "Odp" }, -- was U+F37A
      ods                            = { icon = "\u{F15B}", color = "#78FC4E", name = "Ods" }, -- was U+F378
      odt                            = { icon = "\u{F15B}", color = "#2DCBFD", name = "Odt" }, -- was U+F37C
      pls                            = { icon = "\u{F001}", color = "#ED95AE", name = "Pls" }, -- was U+F0CB9
      ply                            = { icon = "\u{F1B2}", color = "#888888", name = "Ply" }, -- was U+F01A7
      ["pnpm-lock.yaml"]             = { icon = "\u{E71E}", color = "#F9AD02", name = "PnpmLockYaml" }, -- was U+E865
      ["pnpm-workspace.yaml"]        = { icon = "\u{E71E}", color = "#F9AD02", name = "PnpmWorkspaceYaml" }, -- was U+E865
      ppt                            = { icon = "\u{F1C4}", color = "#CB4A32", name = "Ppt" }, -- was U+F0227
      pptx                           = { icon = "\u{F1C4}", color = "#CB4A32", name = "Pptx" }, -- was U+F0227
      ps1                            = { icon = "\u{E683}", color = "#4273CA", name = "Ps1" }, -- was U+F0A0A
      psd1                           = { icon = "\u{E683}", color = "#6975C4", name = "Psd1" }, -- was U+F0A0A
      psm1                           = { icon = "\u{E683}", color = "#6975C4", name = "Psm1" }, -- was U+F0A0A
      pub                            = { icon = "\u{F084}", color = "#E3C58E", name = "Pub" }, -- was U+F0DD6
      r                              = { icon = "\u{E68A}", color = "#2266BA", name = "R" }, -- was U+F07D4
      razor                          = { icon = "\u{E648}", color = "#512BD4", name = "Razor" }, -- was U+F1998
      readme                         = { icon = "\u{F02D}", color = "#EDEDED", name = "Readme" }, -- was U+F00BA
      ["readme.md"]                  = { icon = "\u{F02D}", color = "#EDEDED", name = "ReadmeMd" }, -- was U+F00BA
      redhat                         = { icon = "\u{F316}", color = "#EE0000", name = "Redhat" }, -- was U+F111B
      river                          = { icon = "\u{F17C}", color = "#000000", name = "River" }, -- was U+F381
      rkt                            = { icon = "\u{E6B1}", color = "#9F1D20", name = "Rkt" }, -- was U+F0627
      ["robots.txt"]                 = { icon = "\u{F1B0}", color = "#5D7096", name = "RobotsTxt" }, -- was U+F06A9
      rproj                          = { icon = "\u{E68A}", color = "#358A5B", name = "Rproj" }, -- was U+F05C6
      scm                            = { icon = "\u{E6B1}", color = "#EEEEEE", name = "Scm" }, -- was U+F0627
      security                       = { icon = "\u{F132}", color = "#BEC4C9", name = "Security" }, -- was U+F0483
      ["security.md"]                = { icon = "\u{F132}", color = "#BEC4C9", name = "SecurityMd" }, -- was U+F0483
      sha1                           = { icon = "\u{F084}", color = "#8C86AF", name = "Sha1" }, -- was U+F0565
      sha224                         = { icon = "\u{F084}", color = "#8C86AF", name = "Sha224" }, -- was U+F0565
      sha256                         = { icon = "\u{F084}", color = "#8C86AF", name = "Sha256" }, -- was U+F0565
      sha384                         = { icon = "\u{F084}", color = "#8C86AF", name = "Sha384" }, -- was U+F0565
      sha512                         = { icon = "\u{F084}", color = "#8C86AF", name = "Sha512" }, -- was U+F0565
      sig                            = { icon = "\u{E6B1}", color = "#E37933", name = "Sig" }, -- was U+F0627
      signature                      = { icon = "\u{E6B1}", color = "#E37933", name = "Signature" }, -- was U+F0627
      skp                            = { icon = "\u{F1B2}", color = "#839463", name = "Skp" }, -- was U+F0EEB
      sldasm                         = { icon = "\u{F1B2}", color = "#839463", name = "Sldasm" }, -- was U+F0EEB
      sldprt                         = { icon = "\u{F1B2}", color = "#839463", name = "Sldprt" }, -- was U+F0EEB
      slvs                           = { icon = "\u{F1B2}", color = "#839463", name = "Slvs" }, -- was U+F0EEB
      sml                            = { icon = "\u{E6B1}", color = "#E37933", name = "Sml" }, -- was U+F0627
      srt                            = { icon = "\u{F0FD}", color = "#FFB713", name = "Srt" }, -- was U+F0A16
      ssa                            = { icon = "\u{F0FD}", color = "#FFB713", name = "Ssa" }, -- was U+F0A16
      ste                            = { icon = "\u{F1B2}", color = "#839463", name = "Ste" }, -- was U+F0EEB
      step                           = { icon = "\u{F1B2}", color = "#839463", name = "Step" }, -- was U+F0EEB
      stl                            = { icon = "\u{F1B2}", color = "#888888", name = "Stl" }, -- was U+F01A7
      ["stories.js"]                 = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesJs" }, -- was U+E8B3
      ["stories.jsx"]                = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesJsx" }, -- was U+E8B3
      ["stories.mjs"]                = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesMjs" }, -- was U+E8B3
      ["stories.svelte"]             = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesSvelte" }, -- was U+E8B3
      ["stories.ts"]                 = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesTs" }, -- was U+E8B3
      ["stories.tsx"]                = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesTsx" }, -- was U+E8B3
      ["stories.vue"]                = { icon = "\u{E7BA}", color = "#FF4785", name = "StoriesVue" }, -- was U+E8B3
      stp                            = { icon = "\u{F1B2}", color = "#839463", name = "Stp" }, -- was U+F0EEB
      sub                            = { icon = "\u{F0FD}", color = "#FFB713", name = "Sub" }, -- was U+F0A16
      sv                             = { icon = "\u{F2DB}", color = "#019833", name = "Sv" }, -- was U+F035B
      svg                            = { icon = "\u{F1C5}", color = "#FFB13B", name = "Svg" }, -- was U+F0721
      svgz                           = { icon = "\u{F1C5}", color = "#FFB13B", name = "Svgz" }, -- was U+F0721
      svh                            = { icon = "\u{F2DB}", color = "#019833", name = "Svh" }, -- was U+F035B
      ["tailwind.config.js"]         = { icon = "\u{E60B}", color = "#20C2E3", name = "TailwindConfigJs" }, -- was U+F13FF
      ["tailwind.config.mjs"]        = { icon = "\u{E60B}", color = "#20C2E3", name = "TailwindConfigMjs" }, -- was U+F13FF
      ["tailwind.config.ts"]         = { icon = "\u{E60B}", color = "#20C2E3", name = "TailwindConfigTs" }, -- was U+F13FF
      tbc                            = { icon = "\u{E69F}", color = "#1E5CB3", name = "Tbc" }, -- was U+F06D3
      tcl                            = { icon = "\u{E69F}", color = "#1E5CB3", name = "Tcl" }, -- was U+F06D3
      tumbleweed                     = { icon = "\u{F17C}", color = "#35B9AB", name = "Tumbleweed" }, -- was U+F37D
      txt                            = { icon = "\u{F15C}", color = "#89E051", name = "Txt" }, -- was U+F0219
      typ                            = { icon = "\u{F15B}", color = "#0DBCC0", name = "Typ" }, -- was U+F37F
      v                              = { icon = "\u{F2DB}", color = "#019833", name = "V" }, -- was U+F035B
      vala                           = { icon = "\u{E69B}", color = "#7B3DB9", name = "Vala" }, -- was U+E8D1
      ["vercel.json"]                = { icon = "\u{E615}", color = "#FFFFFF", name = "VercelJson" }, -- was U+E8D3
      vert                           = { icon = "\u{F1FE}", color = "#5586A6", name = "Vert" }, -- was U+E855
      vh                             = { icon = "\u{F2DB}", color = "#019833", name = "Vh" }, -- was U+F035B
      vhd                            = { icon = "\u{F2DB}", color = "#019833", name = "Vhd" }, -- was U+F035B
      vhdl                           = { icon = "\u{F2DB}", color = "#019833", name = "Vhdl" }, -- was U+F035B
      vi                             = { icon = "\u{E62B}", color = "#FEC60A", name = "Vi" }, -- was U+E81E
      ["vite.config.cjs"]            = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigCjs" }, -- was U+E8D7
      ["vite.config.cts"]            = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigCts" }, -- was U+E8D7
      ["vite.config.js"]             = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigJs" }, -- was U+E8D7
      ["vite.config.mjs"]            = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigMjs" }, -- was U+E8D7
      ["vite.config.mts"]            = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigMts" }, -- was U+E8D7
      ["vite.config.ts"]             = { icon = "\u{E60B}", color = "#8040FF", name = "ViteConfigTs" }, -- was U+E8D7
      ["vitest.config.cjs"]          = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigCjs" }, -- was U+E8D9
      ["vitest.config.cts"]          = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigCts" }, -- was U+E8D9
      ["vitest.config.js"]           = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigJs" }, -- was U+E8D9
      ["vitest.config.mjs"]          = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigMjs" }, -- was U+E8D9
      ["vitest.config.mts"]          = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigMts" }, -- was U+E8D9
      ["vitest.config.ts"]           = { icon = "\u{E60B}", color = "#739B1B", name = "VitestConfigTs" }, -- was U+E8D9
      vlcrc                          = { icon = "\u{F03D}", color = "#EE7A00", name = "Vlcrc" }, -- was U+F057C
      webpack                        = { icon = "\u{E60B}", color = "#519ABA", name = "Webpack" }, -- was U+F072B
      wrl                            = { icon = "\u{F1B2}", color = "#888888", name = "Wrl" }, -- was U+F01A7
      wrz                            = { icon = "\u{F1B2}", color = "#888888", name = "Wrz" }, -- was U+F01A7
      xaml                           = { icon = "\u{F121}", color = "#512BD4", name = "Xaml" }, -- was U+F0673
      xls                            = { icon = "\u{F1C3}", color = "#207245", name = "Xls" }, -- was U+F021B
      xlsx                           = { icon = "\u{F1C3}", color = "#207245", name = "Xlsx" }, -- was U+F021B
      xml                            = { icon = "\u{F121}", color = "#E37933", name = "Xml" }, -- was U+F05C0
      xslt                           = { icon = "\u{F121}", color = "#33A9DC", name = "Xslt" }, -- was U+F05C0
      yaml                           = { icon = "\u{E615}", color = "#D70000", name = "Yaml" }, -- was U+E8EB
      yml                            = { icon = "\u{E615}", color = "#D70000", name = "Yml" }, -- was U+E8EB
      toml                           = { icon = "\u{E615}", color = "#9C4221", name = "Toml" }, -- replaces Seti square box
      lock                           = { icon = "\u{F023}", color = "#888888", name = "Lock" }, -- replaces Seti square box
    },

    override_by_filename = {
      ["cargo.toml"]                 = { icon = "\u{E7A8}", color = "#DEA584", name = "CargoToml" },
      ["cargo.lock"]                 = { icon = "\u{F023}", color = "#888888", name = "CargoLock" },
      ["rust-toolchain.toml"]        = { icon = "\u{E7A8}", color = "#DEA584", name = "RustToolchain" },
      ["bunfig.toml"]                = { icon = "\u{E615}", color = "#FBF0DF", name = "BunfigToml" },
      ["bun.lock"]                   = { icon = "\u{F023}", color = "#FBF0DF", name = "BunLock" },
      ["bun.lockb"]                  = { icon = "\u{F023}", color = "#FBF0DF", name = "BunLockb" },
      ["package-lock.json"]          = { icon = "\u{F023}", color = "#CB3837", name = "PackageLockJson" },
      ["yarn.lock"]                  = { icon = "\u{F023}", color = "#2C8EBB", name = "YarnLock" },
      ["pnpm-lock.yaml"]             = { icon = "\u{F023}", color = "#F69220", name = "PnpmLockYaml" },
      ["tsconfig.json"]              = { icon = "\u{E628}", color = "#3178C6", name = "TsConfigJson" },
      ["tsconfig.base.json"]         = { icon = "\u{E628}", color = "#3178C6", name = "TsConfigBaseJson" },
      ["eslint.config.js"]           = { icon = "\u{E615}", color = "#4B32C3", name = "EslintConfigJs" },
      ["eslint.config.mjs"]          = { icon = "\u{E615}", color = "#4B32C3", name = "EslintConfigMjs" },
      ["eslint.config.cjs"]          = { icon = "\u{E615}", color = "#4B32C3", name = "EslintConfigCjs" },
      ["eslint.config.ts"]           = { icon = "\u{E615}", color = "#4B32C3", name = "EslintConfigTs" },
      [".eslintrc"]                  = { icon = "\u{E615}", color = "#4B32C3", name = "EslintRc" },
      [".eslintrc.js"]               = { icon = "\u{E615}", color = "#4B32C3", name = "EslintRcJs" },
      [".eslintrc.cjs"]              = { icon = "\u{E615}", color = "#4B32C3", name = "EslintRcCjs" },
      [".eslintrc.json"]             = { icon = "\u{E615}", color = "#4B32C3", name = "EslintRcJson" },
      [".eslintrc.yml"]              = { icon = "\u{E615}", color = "#4B32C3", name = "EslintRcYml" },
      [".eslintrc.yaml"]             = { icon = "\u{E615}", color = "#4B32C3", name = "EslintRcYaml" },
    },
  },
}
