// the driver for TileLink on-chip communication

`ifndef TC_TILELINK_DRIVER_H
 `define TC_TILELINK_DRIVER_H

class AcquireDriver;
   
   virtual TLinkAcquireInf acq;
   virtual ClockInf clock;
   
   protected mailbox Acquire_h;

   function new (int id, mailbox acq_h);
      core_id = id;
      Acquire_h = acq_h;
   endfunction // new
   
   task execute;
      
      wait(clock.reset == 1'b1);

      acq.valid = 1'b0;
      
      @(negedge clock.reset);
      @(posedge clock.clk);
      #0.1;
      
      while(1'b1) begin
         acq.valid = 1'b0;
         AcquireMessage m;
         Acquire_h.get(m);
         automatic int i = 0;

         while(i==0 || (m.write && i<`TLDataBeats)) begin
            acq.addr = m.addr;
            acq.client_xact_id = core_id;
            acq.uncached = 1'b1;
            if(m.write) begin
               acq.a_type = `acquireWriteUncached;
               acq.data = m.data[`TLDataBits:0];
               m.data = m.data >> `TLDataBits;
            end else
              acq.a_type = `acquireReadShared;

            acq.valid = 1'b1;
            if(acq.ready == 1'b1) i++;
            
            @(posedge clock.clk);
            #0.1;
               
         end // while (i==0 || (m.write && i<`TLDataBeats))
      end // while (1'b1)
   endtask // while

endclass // AcquireDriver


class GrantDriver;

   virtual TLinkGrantInf gnt;
   virtual ClockInf clock;
   
   protected mailbox Grant_h;

   function new(mailbox gnt_h);
      Grant_h = gnt_h;
   endfunction // new

   task execute;
      wait(clock.reset == 1'b1);

      gnt.ready = 1'b0;
      
      @(negedge clock.reset);
      @(posedge clock.clk);
      #0.1;
      
      gnt.ready = 1'b1;
      
      while(1'b1) begin
         GrantMessage m = new();
         automatic int i = 0;

         while(i<`TLDataBeats) begin
            if(gnt.valid) begin
               m.core_id = gnt.client_xact_id;
               m.data[i*TLDataBits +: TLDataBits] = gnt.data;
               i++;
            end
            
            @(posedge clock.clk);
            #0.1;
         end

         gnt.ready = 1'b0;
         Grant_h.put(m);
         gnt.ready = 1'b1;
      end
   endtask // while

endclass // GrantDriver

`endif
