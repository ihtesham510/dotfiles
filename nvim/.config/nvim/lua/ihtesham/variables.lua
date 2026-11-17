return {
  leader = ' ',

  ------------------
  ---- OPTIONS -----
  ------------------

  options = {
    -- line numbers
    number = true,
    relativenumber = false,

    -- tabs & indentation
    tabstop = 2, -- 2 spaces for tabs (prettier default)
    shiftwidth = 2, -- 2 spaces for indent width
    expandtab = true, -- expand tab to spaces

    -- ui
    wrap = false,
    showtabline = 2,
    cursorline = true,
    termguicolors = true,
    background = 'dark', -- colorschemes that support light/dark go dark
    signcolumn = 'yes', -- keep the sign column so text doesn't shift

    -- search
    ignorecase = true, -- ignore case when searching
    smartcase = true, -- mixed case in the search makes it case-sensitive

    -- editing
    backspace = 'indent,eol,start', -- backspace over indent, eol and insert start
    clipboard = 'unnamedplus', -- use the system clipboard as default register
    undofile = true,
    swapfile = false,
    fileencoding = 'utf-8',

    -- splits
    splitright = true, -- vertical splits open to the right
    splitbelow = true, -- horizontal splits open below

    -- scrolling
    scrolloff = 8,
  },

  ------------------
  ---- KEYBINDS ----
  ------------------

  saveFile = '<leader>w',
  quit = '<leader>q',

  open_alpha = '<leader>a',

  defaultOpts = { noremap = true, silent = true },

  moveTextUp = 'K',
  moveTextDown = 'J',

  increment = '+',
  decrement = '-',

  nextTab = 'L',
  prevTab = 'H',
  closeTab = ',',

  exitInsertMode = { 'jk', 'kj' },

  switchWindows = { '<C-h>', '<C-j>', '<C-k>', '<C-l>' }, -- h,j,k,l

  clearHighlights = '<leader>nh',
  exitVisualMode = 'q',

  copyWholeBuffer = '<C-c>',
  deleteAndYankWholeBuffer = '<C-d>',

  -- window management
  splitHorizontal = 'wj',
  splitVertical = 'wl',
  closeSplit = 'wx',
  makeWindowEquals = 'we',
  increaseWindowSize = '<A-(>',
  decreaseWindowSize = '<A-)>',

  telescopeBuiltIn = { 'ss', '<leader>ss' },

  -- finds
  resumeFind = { '<leader>sR', 'sR' },
  findDiagnostics = { 'sd', '<leader>sd' },
  findFiles = { 'ff', '<leader>ff', 'sf', '<leader>sf' },
  findRecentFiles = { 'sr', '<leader>sr' },
  findTodos = { 'st', '<leader>st' },
  findBuffers = '<leader><leader>',
  findConfigFiles = { 'sc', '<leader>sc' },
  findKeymaps = { 'sk', '<leader>sk' },
  findHelpTags = { 'sh', '<leader>sh' },
  -- git
  gitFiles = '<leader>gf',
  gitStash = '<leader>gf',
  gitStatus = '<leader>gf',
  gitCommits = '<leader>gf',
  gitBranches = '<leader>gf',
  gitNextHunk = 'gj',
  gitPrevHunk = 'gk',
  gitFirstHunk = 'gJ',
  gitLastHunk = 'gK',
  gitStageHunk = '<leader>ghs',
  gitStageBuffer = '<leader>ghS',
  gitStageUndo = '<leader>ghu',
  gitHunkReset = '<leader>ghr',
  gitBufferReset = '<leader>ghR',
  gitPreviewHunk = '<leader>ghp',
  gitBlameHunk = '<leader>ghb',
  gitBlameBuffer = '<leader>ghB',
  gitDiffHunk = '<leader>ghd',
  gitDiffBuffer = '<leader>ghD',
  lazyGit = '<leader>gl',

  -- grep
  grep = { 'F', '<leader>F' },
  grepOpenFiles = { 'so', '<leader>so' },
  grepCurrentBuffer = '?',
  grepString = { 'sw', '<leader>sw' },

  -- bookmark
  bmToggle = 'mm',
  bmAnnotation = 'mi',
  bmClean = 'mc',
  bmPrev = 'mk',
  bmNext = 'mj',
  bmClear = 'mx',
  bmList = 'ml',

  -- file explorer (nvim-tree)
  treeOpen = '<leader>e',
  treeToggle = 't',
  treeEdit = 'l',
  treeEditEnter = '<CR>',
  treeFindFiles = 'ff',

  -- lsp
  lspRename = '<leader>rn',
  lspDiagnostics = '<leader>d',
  lspCodeAction = 'ca',
  lspReferences = 'gr',
  lspImplementations = 'gi',
  lspDefinitions = 'gd',
  lspDeclaration = 'gD',
  lspDocumentSymbols = 'go',
  lspWorkspaceSymbols = 'gw',
  lspTypeDefinitions = 'gt',
  lspToggleInlayHints = '<leader>th',

  -- treesitter textobjects
  -- sI (select Inner) , sO (select Outter) , sRhs (select right hand side) , sLhs (select left hand side)
  sOAssignment = 'a=',
  sIAssignment = 'i=',
  sRhsAssignment = 'r=',
  sLhsAssignment = 'l=',
  sOProperty = 'a:',
  sIProperty = 'i:',
  sRhsProperty = 'r:',
  sLhsProperty = 'l:',
  sOParam = 'aa',
  sIParam = 'ia',
  sOCon = 'ai',
  sICon = 'ii',
  sOLoop = 'al',
  sILoop = 'il',
  sOFunc = 'af',
  sIFunc = 'if',
  sOMethod = 'am',
  sIMethod = 'im',
  sOClass = 'ac',
  sIClass = 'ic',

  -- treesitter textobjects: swap
  tsSwapNextParam = '<leader>na',
  tsSwapNextProperty = '<leader>n:',
  tsSwapNextMethod = '<leader>nm',
  tsSwapPrevParam = '<leader>pa',
  tsSwapPrevProperty = '<leader>p:',
  tsSwapPrevMethod = '<leader>pm',

  -- treesitter textobjects: move
  tsNextCallStart = ']f',
  tsNextMethodStart = ']m',
  tsNextClassStart = ']c',
  tsNextCondStart = ']i',
  tsNextLoopStart = ']l',
  tsNextScope = ']s',
  tsNextFold = ']z',
  tsNextCallEnd = ']F',
  tsNextMethodEnd = ']M',
  tsNextClassEnd = ']C',
  tsNextCondEnd = ']I',
  tsNextLoopEnd = ']L',
  tsPrevCallStart = '[f',
  tsPrevMethodStart = '[m',
  tsPrevClassStart = '[c',
  tsPrevCondStart = '[i',
  tsPrevLoopStart = '[l',
  tsPrevCallEnd = '[F',
  tsPrevMethodEnd = '[M',
  tsPrevClassEnd = '[C',
  tsPrevCondEnd = '[I',
  tsPrevLoopEnd = '[L',

  -- treesitter textobjects: repeatable move
  tsRepeatMove = ';',
  tsRepeatMoveOpposite = ',',
  tsFind = 'f',
  tsFindBack = 'F',
  tsTill = 't',
  tsTillBack = 'T',

  -- telescope internal keybindings
  tsScrollUp = { '<C-j>', '[' },
  tsScrollDown = { '<C-k>', ']' },
  tsCloseAction = { 'esc', 'q' },
  tsDefaultSelect = { 'l', '<CR>' },
}
