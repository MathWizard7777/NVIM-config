function Map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Window Focusing
Map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
Map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
Map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
Map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

Map("t", "<C-h>", "<cmd>wincmd h<CR>")
Map("t", "<C-j>", "<cmd>wincmd j<CR>")
Map("t", "<C-k>", "<cmd>wincmd k<CR>")
Map("t", "<C-l>", "<cmd>wincmd l<CR>")

-- Window Resizing
Map("n", "<C-Up>", ":resize -2<CR>")
Map("n", "<C-Down>", ":resize +2<CR>")
Map("n", "<C-Left>", ":vertical resize -2<CR>")
Map("n", "<C-Right>", ":vertical resize +2<CR>")

Map("t", "<C-Up>", "<cmd>resize -2<CR>")
Map("t", "<C-Down>", "<cmd>resize +2<CR>")
Map("t", "<C-Left>", "<cmd>vertical resize -2<CR>")
Map("t", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Moving Text Blocks
Map("v", "J", ":m '>+1<CR>gv=gv")
Map("v", "K", ":m '<-2<CR>gv=gv")
Map("v", "<", "<gv")
Map("v", ">", ">gv")

-- Yank to system clipboard
Map({'n', 'v'}, '<leader>y', '"+y')

-- Paste from system clipboard
Map({'n', 'v'}, '<leader>p', '"+p')
Map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
Map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Clear highlights on search when pressing <Esc> in normal mode
Map('n', '<Esc>', '<cmd>nohlsearch<CR>')

Map('n', '<F20>', function()
    vim.cmd('silent w') -- Saves without showing the "written" message
    vim.cmd('!crr %')   -- Runs your script
end)

vim.api.nvim_set_keymap('n', '<leader>d', ':lua SaveForDragAndDrop()<CR>', { noremap = true, silent = true })

function SaveForDragAndDrop()
    local current_file = vim.fn.expand('%:p')
    if current_file == '' then
        print('cp-drag: no file in this buffer')
        return
    end

    vim.cmd('silent! update')

    -- Convert WSL path to Windows format
    local windows_path = vim.fn.system('wslpath -w ' .. vim.fn.shellescape(current_file)):gsub("[\r\n]", "")

    -- Stash path in temp file as a fallback for the popup script
    local temp_file = '/mnt/c/Users/chand/AppData/Local/Temp/wsl_drag_path.txt'
    local file = io.open(temp_file, 'w')
    if file then
        file:write(windows_path)
        file:close()
    end

    -- Launch the popup non-blocking. Pass the path directly as an arg.
    -- jobstart won't resolve powershell.exe via PATH, so give it the full path.
    local powershell = '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'
    local script = 'C:\\Users\\chand\\bin\\cp-drag.ps1'
    vim.fn.jobstart({
        powershell,
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', script,
        '-FilePath', windows_path,
    }, { detach = true })

    print('cp-drag: ' .. windows_path)
end

-- :archive cf    -> copy current file to <root>/codeforces/<name>_<timestamp>.cpp
-- :archive usaco -> copy current file to <root>/usaco/<name>_<timestamp>.cpp
local SUBMISSIONS_ROOT = vim.fn.expand('~/programming/comp-prog/submissions')

vim.api.nvim_create_user_command('Archive', function(opts)
    local subdir = ({ cf = 'codeforces', codeforces = 'codeforces', usaco = 'usaco' })[opts.args]
    if not subdir then
        vim.notify('archive: expected "cf" or "usaco"', vim.log.levels.ERROR)
        return
    end

    local src = vim.fn.expand('%:p')
    if src == '' or vim.fn.filereadable(src) == 0 then
        vim.notify('archive: current buffer has no readable file', vim.log.levels.ERROR)
        return
    end
    vim.cmd('silent! update') -- save before copying

    local dir = SUBMISSIONS_ROOT .. '/' .. subdir
    vim.fn.mkdir(dir, 'p')

    local stem  = vim.fn.expand('%:t:r')           -- "main"
    local ext   = vim.fn.expand('%:e')             -- "cpp"
    local stamp = os.date('%Y%m%d_%H%M%S')         -- 20260531_143022
    local dest  = string.format('%s/%s_%s.%s', dir, stem, stamp, ext)

    -- guard against a collision within the same second
    local i = 1
    while vim.fn.filereadable(dest) == 1 do
        dest = string.format('%s/%s_%s_%d.%s', dir, stem, stamp, i, ext)
        i = i + 1
    end

    if vim.fn.writefile(vim.fn.readfile(src, 'b'), dest, 'b') == 0 then
        vim.notify('archived -> ' .. dest)
    else
        vim.notify('archive: failed to write ' .. dest, vim.log.levels.ERROR)
    end
end, {
    nargs = 1,
    complete = function() return { 'cf', 'usaco' } end,
    desc = 'Archive current file to submissions/{codeforces,usaco}',
})

-- let lowercase ":archive" expand to ":Archive" (only as the command word)
vim.cmd([[cnoreabbrev <expr> archive (getcmdtype() == ':' && getcmdline() ==# 'archive') ? 'Archive' : 'archive']])
