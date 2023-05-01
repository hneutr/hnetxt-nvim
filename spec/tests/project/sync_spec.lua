local stub = require('luassert.stub')
local Path = require("hneutil-nvim.path")

local Reference = require("hnetxt-lua.text.reference")
local Project = require("hnetxt-lua.project")

local test_dir = Path.joinpath(Path.tempdir(), "test-dir")
local test_file = Path.joinpath(test_dir, "test-file.md")

local Sync = require("hnetxt-nvim.project.sync")

describe("sync", function()
    before_each(function()
        Path.rmdir(test_dir, true)
        Path.mkdir(test_dir)
        stub(Project, "root_from_path")
        Project.root_from_path.returns(test_dir)

        vim.b.hnetxt_project_root = test_dir
    end)

    after_each(function()
        Path.rmdir(test_dir, true)
        Project.root_from_path:revert()
    end)

    describe("on enter", function()
        local read_markers = Sync.read_markers

        before_each(function()
            Sync.read_markers = function() return { key = 'val' } end
        end)

        after_each(function()
            Sync.read_markers = read_markers
        end)

        it("inits properly", function()
            assert.is_nil(vim.g.deleted_markers)
            assert.is_nil(vim.b.markers)
            assert.is_nil(vim.b.renamed_markers)
            assert.is_nil(vim.b.deleted_markers)
            assert.is_nil(vim.b.created_markers)

            Sync.buf_enter()

            assert.is_true(vim.tbl_isempty(vim.g.deleted_markers))
            assert.is_true(vim.tbl_isempty(vim.b.renamed_markers))
            assert.is_true(vim.tbl_isempty(vim.b.deleted_markers))
            assert.is_true(vim.tbl_isempty(vim.b.created_markers))

            assert.are.same(vim.b.markers, { key = 'val' })
        end)
    end)

    describe("read_markers", function()
        before_each(function()
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_command("buffer " .. buf)
        end)

        it("finds markers", function()
            local buffer_text = { "[marker 1]()", "", "[ref](ref)", "[marker 2]()", "nonmarker", ""}
            vim.api.nvim_buf_set_lines(0, 0, -1, true, buffer_text)

            local markers = Sync.read_markers()
            assert.are.same(markers, { ['marker 1'] = 1, ['marker 2'] = 4})
        end)
    end)

    describe("on change", function()
        local Location = require("hnetxt-nvim.text.location")

        before_each(function()
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_command("buffer " .. buf)

            Location.update = function() return end
        end)

        after_each(function()
            Location.update = location_update
        end)

        describe(".get_deletions", function()
            it("finds deletions", function()
            local old = { one = 1, two = 2 }
            local new = { one = 1 }

            assert.are.same(Sync.get_deletions(old, new), { "two" })
            end)
        end)

        describe(".get_creations", function()
            it("finds creations", function()
            local old = { one = 1 }
            local new = { one = 1, two = 2 }

            assert.are.same(Sync.get_creations(old, new), { "two" })
            end)
        end)

        describe(".check_rename", function()
            it("finds rename", function()
            local old_markers = { one = 1, two_a = 2 }
            local new_markers = { one = 1, two_b = 2 }
            local deletions = {"two_a"}
            local creations = {"two_b"}

            assert.is_true(Sync.check_rename(old_markers, new_markers, creations, deletions))
            end)

            it("doesn't find rename", function()
            local old_markers = { one = 1, two = 2 }
            local new_markers = { one = 1, one_and_a_half = 2, two = 3 }
            local deletions = {}
            local creations = {"one_and_a_half"}

            assert.is_false(Sync.check_rename(old_markers, new_markers, creations, deletions))
            end)

            it("doesn't find rename (2)", function()
            local old_markers = { one = 1, two = 2 }
            local new_markers = { one = 1, three = 3 }
            local deletions = {"two"}
            local creations = {"three"}

            assert.is_false(Sync.check_rename(old_markers, new_markers, creations, deletions))
            end)
        end)

        describe(".record_rename", function()
            it("basic case", function()
            local actual = Sync.update_renames("old", "new", {})
            assert.are.same(actual, { old = 'new' })
            end)

            it("rename of something else", function()
            local actual = Sync.update_renames("old", "new", {older = 'old'})
            assert.are.same(actual, { older = 'new' })
            end)

            it("doesn't overwrite stuff", function()
            local actual = Sync.update_renames("old", "new", {other_old = 'other_new'})
            assert.are.same(actual, { old = 'new', other_old = 'other_new' })
            end)
        end)

        describe(".update_creations", function()
            it("base case", function()
            local actual = Sync.update_creations({"old"}, {"new"}, {old = true, other = true})
            assert.are.same(actual, { other = true, new = true })
            end)
        end)

        describe(".update_deletions", function()
            it("base case", function()
            local actual = Sync.update_deletions({"old"}, {"new"}, {new = true, other = true})
            assert.are.same(actual, { other = true, old = true })
            end)
        end)

        it("records a rename", function()
            local old_text = { "[marker 1]()" }
            vim.api.nvim_buf_set_lines(0, 0, -1, true, old_text)
            Sync.buf_enter()

            vim.b.renamed_markers = { ['marker 2'] = 'marker 2a'}

            local new_text = { "[marker 1a]()" }
            vim.api.nvim_buf_set_lines(0, 0, -1, true, new_text)
            Sync.buf_change()

            assert.are.same(vim.b.renamed_markers, { ['marker 1'] = 'marker 1a', ['marker 2'] = 'marker 2a'})
        end)

        it("records a deletion", function()
            local old_text = { "[marker 1]()" }
            vim.api.nvim_buf_set_lines(0, 0, -1, true, old_text)
            Sync.buf_enter()

            vim.b.created_markers = { ['marker 1'] = true}

            local new_text = {}
            vim.api.nvim_buf_set_lines(0, 0, -1, true, new_text)
            Sync.buf_change()

            assert.are.same(vim.b.deleted_markers, { ['marker 1'] = true })
            assert.is_true(vim.tbl_isempty(vim.b.created_markers))
            assert.is_true(vim.tbl_isempty(vim.b.markers))
        end)

        it("records a creation", function()
            local old_text = {}
            vim.api.nvim_buf_set_lines(0, 0, -1, true, old_text)
            Sync.buf_enter()

            vim.b.deleted_markers = { ['marker 1'] = true}

            local new_text = { "[marker 1]()" }

            vim.api.nvim_buf_set_lines(0, 0, -1, true, new_text)
            Sync.buf_change()

            assert.are.same(vim.b.created_markers, { ['marker 1'] = true })
            assert.is_true(vim.tbl_isempty(vim.b.deleted_markers))
            assert.are.same(vim.b.markers, { ['marker 1'] = 1 })
        end)
    end)

    describe("on leave", function()
        before_each(function()
            stub(Path, "current_file")
            Path.current_file.returns("path")

            stub(Reference, 'get_referenced_mark_locations')
            Reference.get_referenced_mark_locations.returns({})
        end)

        after_each(function()
            Path.current_file:revert()
            Reference.get_referenced_mark_locations:revert()
        end)

        describe("process_renames", function()
            it("base case", function()
                local renames = {one = 'one a', two = 'two a'}
                local creations = {}
                local deletions = {}
                local references = {['path:one'] = true}

                local a_updates, a_renames, a_references = Sync.process_renames(
                    renames,
                    deletions,
                    creations,
                    references
                )
                assert.are.same({{new_location = "path:one a", old_location = "path:one"}}, a_updates)
                assert.are.same({["path:one a"] = true}, a_references)
                assert.are.same(renames, a_renames)
            end)

            it("handles deletion", function()
                local renames = {one = 'one a', two = 'two a'}
                local references = {['path:one'] = true}
                local creations = {}
                local deletions = {["two a"] = true}

                local a_updates, a_renames, a_references = Sync.process_renames(
                    renames,
                    deletions,
                    creations,
                    references
                )

                assert.are.same({{new_location = "path:one a", old_location = "path:one"}}, a_updates)
                assert.are.same({["path:one a"] = true}, a_references)
                assert.are.same({one = 'one a'}, a_renames)
            end)

            it("handles creation", function()
                local renames = {one = 'one a', two = 'two a'}
                local references = {['path:one'] = true}
                local creations = {one = true}
                local deletions = {["two a"] = true}

                local a_updates, a_renames, a_references = Sync.process_renames(
                    renames,
                    deletions,
                    creations,
                    references
                )

                assert.are.same({}, a_updates)
                assert.are.same({["path:one a"] = true}, a_references)
                assert.are.same({one = 'one a'}, a_renames)
            end)

            it("adds references", function()
                Reference.get_referenced_mark_locations.returns({"new"})

                local renames = {one = 'one a', two = 'two a'}
                local references = {['path:one'] = true}
                local creations = {}
                local deletions = {["two a"] = true}

                local a_updates, a_renames, a_references = Sync.process_renames(
                    renames,
                    deletions,
                    creations,
                    references
                )

                assert.are.same({{new_location = "path:one a", old_location = "path:one"}}, a_updates)
                assert.are.same({["path:one a"] = true, new = true}, a_references)
                assert.are.same(renames, a_renames)
            end)
        end)

        describe("process_creations", function()
            it("handles an unrenamed case", function()
                local creations = {two = true}
                local renames = {one = 'one a'}
                local deletions = {two = "path/to/two"}
                local references = {['path/to/two:two'] = true}

                local updates, deletions, references = Sync.process_creations(
                    creations,
                    renames,
                    deletions,
                    references
                )

                assert.are.same({{new_location = "path:two", old_location = "path/to/two:two"}}, updates)
                assert.are.same({}, deletions)
                assert.are.same({['path:two'] = true}, references)
            end)

            it("handles a rename", function()
                local creations = {two = true}
                local renames = {one = 'one a', two = 'two a'}
                local deletions = {two = "path/to/two"}
                local references = {['path/to/two:two'] = true}

                local updates, deletions, references = Sync.process_creations(
                    creations,
                    renames,
                    deletions,
                    references
                )

                assert.are.same({{new_location = "path:two a", old_location = "path/to/two:two"}}, updates)
                assert.are.same({}, deletions)
                assert.are.same({['path:two a'] = true}, references)
            end)
        end)

        describe("process_deletions", function()
            it("handles an unrenamed case", function()
                local deletions = { one = true }
                local previous_dels = { two = "path/to/two" }
                local references = { ['path:one'] = true }

                local previous_dels = Sync.process_deletions(deletions, previous_dels, references)

                assert.are.same({two = 'path/to/two', one = 'path'}, previous_dels)
            end)
        end)
    end)
end)
