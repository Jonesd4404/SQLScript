       begin transaction

       update rc
              set rc.[Status]=20
       from VX_Reorder_Control rc
       where rc.[Status] = 60
              and rc.PONumber = '282267'

       -- only one row should be changed

       select *
       from VX_Reorder_Control 
       where PONumber='282267'

       -- commit transaction


Then we would need to rerun the vx_submitregs stored procedure

                EXEC HPB_Logistics.dbo.VX_SubmitReqs 'kbeverly', 0
