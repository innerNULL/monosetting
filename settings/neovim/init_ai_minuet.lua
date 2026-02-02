-- init.lua (Lazy.nvim)

-- =========================================================
-- Bootstrap Lazy.nvim
-- =========================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =========================================================
-- Plugins
-- =========================================================
require("lazy").setup({
  -- ---------- Minuet AI (Gemini) ----------
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("minuet").setup({
      provider = "openai_compatible",
      provider_options = {
        openai_compatible = {
          api_key = "OPENROUTER_API_KEY", -- env var name, not the key itself
          end_point = "https://openrouter.ai/api/v1/chat/completions",
          model = "google/gemini-2.5-flash",
          name = "OpenRouter",
          stream = true,
          optional = {
            max_tokens = 56,
            top_p = 0.9,

            -- OpenRouter-specific routing hints
            -- NOTE: this must be under `extra_body` for OpenAI-compatible APIs
            extra_body = {
              provider = {
                sort = "throughput",
              },
            },
          },
        },
      },
    })
    end,
  },

  -- ---------- Auto-complete ----------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        -- IMPORTANT: include minuet source
        sources = cmp.config.sources({
          { name = "minuet" }, -- <-- Minuet AI completion
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        }),

        -- IMPORTANT: LLM sources are slower; increase timeout
        performance = {
          fetching_timeout = 2000, -- ms (try 1500~4000 if needed)
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },

  -- ---------- File tree ----------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 35 },
        renderer = { icons = { show = { git = true, folder = true, file = true, folder_arrow = true } } },
        filters = { dotfiles = false },
      })
    end,
  },

  -- ---------- Finder / search ----------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    config = function()
      require("telescope").setup({})
    end,
  },
})

-- =========================================================
-- Your options (unchanged)
-- =========================================================
vim.cmd("syntax on")
vim.opt.showmode = true
vim.opt.showcmd = true
vim.opt.encoding = "utf-8"
vim.cmd("filetype indent on")

vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.textwidth = 200

vim.opt.showmatch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true
vim.opt.history = 1000

vim.opt.background = "dark"
vim.cmd("colorscheme evening")
vim.opt.termguicolors = true

vim.opt.laststatus = 2
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.colorcolumn = "100"
vim.opt.mouse = ""

-- =========================================================
-- Keymaps (unchanged)
-- =========================================================
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
