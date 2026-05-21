
class svbt_reset_bfm extends svbt_base_unit;
    
    virtual reset_intf.drv smp_drv;
    
    function new(virtual reset_intf.drv smp_drv, string name, int id);
        super.new(name,id);
        this.smp_drv = smp_drv;
    
    endfunction: new
    
    task run();
        smp_drv.drv_cb.reset <= 1'b1;
        repeat(5) @(smp_drv.drv_cb);
        
        smp_drv.drv_cb.reset <= 1'b0;
        repeat(2) @(smp_drv.drv_cb);
        
    endtask: run

endclass: svbt_reset_bfm