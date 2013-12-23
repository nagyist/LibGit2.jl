@with_repo_access begin
    
    begin # test read note for object
        id = Oid("36060c58702ed4c2a40832c51758d5344201d89a")
        obj = lookup(test_repo, id)
        n = notes(obj)
        @test message(n) == "note text\n" 
        @test oid(n) == Oid("94eca2de348d5f672faf56b0decafa5937e3235e")
    end

    begin # test read note for object from ref
        id = Oid("36060c58702ed4c2a40832c51758d5344201d89a")
        obj = lookup(test_repo, id)
        n = notes(obj, "refs/notes/commits")
        @test message(n) == "note text\n" 
        @test oid(n) == Oid("94eca2de348d5f672faf56b0decafa5937e3235e")
    end

    begin # test_object_without_note
        id = Oid("8496071c1b46c854b31185ea97743be6a8774479")
        obj = lookup(test_repo, id)
        @test notes(obj) == nothing
    end

    begin # test_nil_ref_lookup
        id = Oid("36060c58702ed4c2a40832c51758d5344201d89a")
        obj = lookup(test_repo, id)
        @test notes(obj, "refs/notes/missing") == nothing
    end

    begin # iterate over notes
        for (note_blob, ann_obj) in iter_notes(test_repo, "refs/notes/commits")
            @test content(note_blob) == "note text\n"
            @test (ann_obj |> oid) == Oid("36060c58702ed4c2a40832c51758d5344201d89a")
        end
    end

    begin # test each note iterable
        @test isa(iter_notes(test_repo, "refs/notes/commits"), Task)
    end

    begin # test default ref
        @test note_default_ref(test_repo) == "refs/notes/commits"
    end
end

#TODO: NOTE WRITE TESTS

@with_tmp_repo_access begin
    sig = Signature("Julia", "julia@julia.com")
    id = Oid("8496071c1b46c854b31185ea97743be6a8774479")
    msg = "This is the note message\n\nThis note is created from Rugged"
    obj = lookup(test_repo, id)

    note_id = note!(obj, msg,
                    committer=sig,
                    author=sig,
                    ref="refs/notes/test")

    @test note_id == Oid("38c3a690c474d8dcdb13088205a464a60312eec4")
    # note is actually a blob
    blob = lookup(test_repo, note_id)
    @test oid(blob) == note_id
    @test raw_content(blob) == msg
    @test isa(blob, GitBlob) 

    n = notes(obj, "refs/notes/test")
    @test oid(n) == note_id
    @test message(n) == msg
end