-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Fixed Window Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })

-- Auto Save Toggle
vim.keymap.set("n", "<leader>as", function()
  if vim.g.auto_save_enabled == true then
    vim.g.auto_save_enabled = false
    print("Auto-Save: OFF")
  else
    vim.g.auto_save_enabled = true
    print("Auto-Save: ON")
  end
end, { desc = "Toggle Auto-Save" })

-- Manual Save
vim.keymap.set("n", "<leader>s", ":w<CR>", { desc = "Save File" })

-- Manual Format
vim.keymap.set("n", "<leader>fm", function()
  LazyVim.format({ force = true })
end, { desc = "Format Document (Manual)" })

-- 1. Jump 10 lines up/down with Alt+k and Alt+j
vim.keymap.set("n", "<A-k>", "10k", { noremap = true, silent = true })
vim.keymap.set("n", "<A-j>", "10j", { noremap = true, silent = true })

-- VSCode Folding (if using vscode-neovim)
vim.keymap.set("n", "zc", '<cmd>call VSCodeNotify("editor.fold")<cr>')
vim.keymap.set("n", "zo", '<cmd>call VSCodeNotify("editor.unfold")<cr>')
vim.keymap.set("n", "za", '<cmd>call VSCodeNotify("editor.toggleFold")<cr>')

-- [[ stops yanking after paste over ]]
vim.keymap.set("x", "p", "P", { silent = true })

-- 2. Move lines up/down with Alt+u and Alt+d
-- Moving current line (Normal Mode)
vim.keymap.set("n", "<A-u>", ":m -2<CR>==", { silent = true })
vim.keymap.set("n", "<A-d>", ":m +1<CR>==", { silent = true })

-- Moving selected lines (Visual Mode)
vim.keymap.set("v", "<A-u>", ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<A-d>", ":m '>+1<CR>gv=gv", { silent = true })

-- 3. Delete without saving to clipboard (sent to black hole register "_")
vim.keymap.set({ "n", "v" }, "d", '"_d', { silent = true })
vim.keymap.set({ "n", "v" }, "dd", '"_dd', { silent = true })
