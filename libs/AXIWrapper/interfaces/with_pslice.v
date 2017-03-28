
`timescale 1 ns / 1 ps

//slv_reg0 - The address for the memory location that we plan on reading
//slv_reg1 - The go signal that is used to start the AXI master into fetching that data
//slv_reg2 - The memory location where the read data end up

	module axi_reader #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 7
	)
	(
		// Users to add ports here
        	input wire m_aclk,
        	input wire m_aresetn,

        	//AXI Master signals
        	        //Write channel
        	output wire [31:0] m_awaddr,
        	output wire [2:0] m_awprot,
        	output wire m_awvalid,
        	input wire m_awready,
        	output wire m_wdata,
        	output wire [3:0] m_wstrb,
        	output wire m_wvalid,
        	input wire m_wready,
        	input wire [1:0] m_bresp,
        	input wire m_bvalid,
        	output wire m_bready,
        	        //read channel
        	output wire [31:0] m_araddr,
        	output wire [2:0] m_arprot,
        	output wire m_arvalid,
        	input wire m_arready,
        	input wire [31:0] m_rdata,
        	input wire [1:0] m_rresp,
        	input wire m_rvalid,
        	output wire m_rready,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 4;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 32
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg4;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg5;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg6;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg7;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg8;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg9;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg10;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg11;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg12;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg13;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg14;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg15;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg16;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg17;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg18;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg19;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg20;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg21;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg22;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg23;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg24;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg25;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg26;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg27;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg28;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg29;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg30;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg31;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;

	reg [C_S_AXI_DATA_WIDTH-1:0] m_araddr_reg;


	//----------------------------------------------------
	//signals for controling the legup slave interface
	reg [1:0] avs_o_s1_address_reg;
	reg avs_o_s1_read_reg;
	reg avs_o_s1_write_reg;
	reg [31:0] avs_o_s1_writedata_reg;
	wire  [31:0] avs_o_s1_readdata;	
	
	wire [1:0] avs_o_s1_address;
	wire avs_o_s1_read;
	wire avs_o_s1_write;
	wire [31:0] avs_o_s1_writedata;

	wire [31:0]final_result;
	
	assign avs_o_s1_address = avs_o_s1_address_reg;
	assign avs_o_s1_read = avs_o_s1_read_reg;
	assign avs_o_s1_write = avs_o_s1_write_reg;
	assign avs_o_s1_writedata = avs_o_s1_writedata_reg;	

	//pSlice signals
	wire slice_finish;	

	reg [1:0] avs_p_s1_address_reg;
	reg avs_p_s1_read_reg;
	reg avs_p_s1_write_reg;
	reg [31:0] avs_p_s1_writedata_reg;
	wire  [31:0] avs_p_s1_readdata;	
	
	wire [1:0] avs_p_s1_address;
	wire avs_p_s1_read;
	wire avs_p_s1_write;
	wire [31:0] avs_p_s1_writedata;
	
	assign avs_p_s1_address = avs_p_s1_address_reg;
	assign avs_p_s1_read = avs_p_s1_read_reg;
	assign avs_p_s1_write = avs_p_s1_write_reg;
	assign avs_p_s1_writedata = avs_p_s1_writedata_reg;	
	//----------------------------------------------------

	//----------------------------------------------------
	//signals for controling the legup master interface
	wire [127:0] avm_o_ACCEL_readdata;
	reg avm_o_ACCEL_waitrequest;
	wire [31:0] avm_o_ACCEL_address;
	wire [127:0] avm_o_ACCEL_writedata;
	wire avm_o_ACCEL_write;
	wire avm_o_ACCEL_read;

	wire [127:0] avm_p_ACCEL_readdata;
	reg avm_p_ACCEL_waitrequest;
	wire [31:0] avm_p_ACCEL_address;
	wire [127:0] avm_p_ACCEL_writedata;
	wire avm_p_ACCEL_write;
	wire avm_p_ACCEL_read;
	//----------------------------------------------------

	reg [31:0] cycle_counter;
	reg [31:0] slice_cycle_counter;
	reg [31:0] fifo_full_count;
	reg [31:0] fifo_empty_count;
	reg [31:0] mem_waitrequest_count;
	reg slice_finish_dly;
	reg legup_finish_dly;
	wire legup_finish_pulse;
	wire slice_finish_pulse;
	assign legup_finish_pulse = legup_finish && !legup_finish_dly;
	assign slice_finish_pulse = slice_finish && !slice_finish_dly;
	always @(posedge m_aclk) begin
		if(m_aresetn == 1'b0) begin
			legup_finish_dly <= 1'b0;	
			slice_finish_dly <= 1'b0;	
		end else begin
			legup_finish_dly <= legup_finish;
			slice_finish_dly <= slice_finish;
		end 
	end
	//~~~~~~~~~~~~~~DEBUG~~~~~~~~~~~~~~~~~~~~
	always @(posedge m_aclk) begin
		if(m_aresetn == 1'b0) begin
			slv_reg4 <= 32'd0;
			slv_reg5 <= 32'd0;
			slv_reg6 <= 32'd0;
			slv_reg7 <= 32'd0;
			slv_reg8 <= 32'd0;
			fifo_full_count <= 32'd0;
			fifo_empty_count <= 32'd0;
			cycle_counter <= 32'd0;
			slice_cycle_counter <= 32'd0;
		end else begin
                        if(slv_reg1 == 32'd1) begin
				slv_reg4 <= 32'd0;
				slv_reg6 <= 32'd0;
                                slv_reg5 <= 32'd0;
                                slv_reg7 <= 32'd0;
                                slv_reg8 <= 32'd0;
				fifo_full_count <= 32'd0;
				fifo_empty_count <= 32'd0;
                                cycle_counter <= 32'd0;
                                slice_cycle_counter <= 32'd0;
                        end else begin
                                cycle_counter <= cycle_counter + 32'd1;
                                slice_cycle_counter <= slice_cycle_counter + 32'd1;
                                if(avm_o_ACCEL_waitrequest) begin
                                        mem_waitrequest_count <= mem_waitrequest_count + 32'd1;
                                end
				if(fifo_full == 1'b1) begin
					fifo_full_count <= fifo_full_count + 32'd1;
				end
				if(fifo_empty == 1'b1) begin
					fifo_empty_count <= fifo_empty_count + 32'd1;
				end
                        end

			if(slice_finish_pulse) begin
				slv_reg8 <= slice_cycle_counter;
			end

                        if(legup_finish_pulse) begin
                                slv_reg7 <= cycle_counter;
                                slv_reg5 <= mem_waitrequest_count;
				slv_reg4 <= fifo_full_count;
				slv_reg6 <= fifo_empty_count;
                        end

		end
	end
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	reg read_req_ack;
	reg m_rready_reg;
	reg m_arvalid_reg;	
	reg init_txn_ff;
	reg init_txn_ff2;
	reg init_txn_edge;
	wire init_txn_pulse;
	wire read_resp_error;
	wire legup_finish;

	assign m_arprot = 3'b001;
	assign m_rready = m_rready_reg;
	assign m_araddr = m_araddr_reg;
	assign m_arvalid = m_arvalid_reg;

	assign avm_p_ACCEL_readdata = {96'd0, read_data_reg};
	assign m_araddr = avm_p_ACCEL_writedata[31:0];

	//State Machine to control legup->AXI read transactions
	reg [3:0]read_cur_state;
	reg [3:0]read_next_state;
	reg [31:0] read_data_reg;

	//Read Channel state registers
	always @(posedge m_aclk) begin
		if(m_aresetn == 0) begin
			read_cur_state <= 4'd0;
			read_data_reg <= 32'd0;
		end else begin
			read_cur_state <= read_next_state;
			if(read_cur_state == 4'b0010) begin
				read_data_reg <= m_rdata;
			end
		end
	end 

	//Read Channel state transistion logic
	always @(*) begin
		read_next_state = read_cur_state;	
		avm_p_ACCEL_waitrequest = 1'b0;
		m_arvalid_reg = 1'b0;
		m_rready_reg = 1'b0;
		fifo_write = 1'b0;
		case(read_cur_state)
			4'b0000 : begin //waiting for the read request 
					avm_p_ACCEL_waitrequest = avm_p_ACCEL_read || fifo_full;
					if(avm_p_ACCEL_read && !fifo_full) begin 
						read_next_state = 4'b0001;
					end
				 end
			4'b0001 : begin //Read address Channel 
					avm_p_ACCEL_waitrequest = 1'b1;
					m_arvalid_reg = 1'b1;
					if(m_arready) 
						read_next_state = 4'b0010;	
				end 
			4'b0010 : begin //Read Data Channel
					avm_p_ACCEL_waitrequest = 1'b1;
					if(m_rvalid)
						read_next_state = 4'b0011;
				end
			4'b0011 : begin //Data Collection
					avm_p_ACCEL_waitrequest = 1'b0;
					m_rready_reg = 1'b1;
					fifo_write = 1'b1;
					read_next_state = 4'b0000;
				end
			default : begin
					read_next_state = 4'b0000;
				end

		endcase
	end
	
	reg fifo_write;
	wire [31:0] fifo_data_out;
	reg [31:0] o_readdata_reg;	
	reg fifo_read;
	wire fifo_full;
	wire fifo_empty;
	assign avm_o_ACCEL_readdata = {96'd0, o_readdata_reg};

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Original circuit FIFO read FSM
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	reg [2:0] o_read_cur_state;
	reg [2:0] o_read_next_state;
	
	//o_read state registers
	always @(posedge m_aclk) begin
		if(m_aresetn == 1'b0) begin
			o_readdata_reg <= 32'd0;
			o_read_cur_state  <= 3'b000;
		end else begin
			if(o_read_cur_state == 3'b001)
				o_readdata_reg <= fifo_data_out;

			o_read_cur_state <= o_read_next_state;
		end
	end

	//o_read state transistions
	always @(*) begin
		avm_o_ACCEL_waitrequest = 1'b0;		
		fifo_read = 1'b0;
		o_read_next_state = o_read_cur_state;
		case(o_read_cur_state)
				//Idle state	
			3'b000: begin
					avm_o_ACCEL_waitrequest = avm_o_ACCEL_read;	
					if(avm_o_ACCEL_read)
					begin
						if(slice_finish || !fifo_empty) begin
							o_read_next_state = 3'b001;
							fifo_read = 1'b1;
						end
					end
				end
				//read state	
			3'b001: begin
					avm_o_ACCEL_waitrequest = 1'b1;
					o_read_next_state = 3'b010;
				end
				//waitrequest state	
			3'b010: begin
					avm_o_ACCEL_waitrequest = 1'b0;
					o_read_next_state = 3'b000;
				end
			default: begin
					o_read_next_state = 3'b000;
				end
		endcase
	end
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	wire [31:0] fifo_debug;

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//Fifo instantiation
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        //Synchronus FIFO is used to connect the slice and the original component together
        sync_fifo sync_fifo_inst(
                .fifo_debug(fifo_debug),
                .clk(m_aclk),
                .reset(~m_aresetn),
                //reads that are returned from the program slice are fed directly into the fifo
                .wr_en(fifo_write),
                .din(read_data_reg),
                //Hooking up the read singles directly to the FIFO
                .rd_en(fifo_read),
                .dout(fifo_data_out),
                //This is connected to the slice wait_request signal so that it cannot run ahead too far
                .full(fifo_full),
                .empty(fifo_empty)
        );

	
	//##################################################################################


	//##################################################################################


	//##########################################################
	//State Machine for the initialisation of the legup circuit
	//##########################################################
	reg [2:0] curr_state;
	reg [2:0] next_state;
	
	//State registers
	always @(posedge m_aclk) begin
		if(m_aresetn == 1'b0) begin
			curr_state <= 2'd0;
		end
		else begin
			curr_state <= next_state;
		end
	end	

	//State logic and state transition logic
	always @(posedge m_aclk) begin
		if(m_aresetn == 1'b0) begin
			next_state <= 32'd0;
			avs_o_s1_address_reg <= 32'd0;
			avs_o_s1_read_reg <= 1'b0;
			avs_o_s1_write_reg <= 1'b0;
			avs_o_s1_writedata_reg <= 32'd0;
			avs_p_s1_address_reg <= 32'd0;
			avs_p_s1_read_reg <= 1'b0;
			avs_p_s1_write_reg <= 1'b0;
			avs_p_s1_writedata_reg <= 32'd0;
			slv_reg3 <= 32'd0;
			slv_reg2 <= 32'd0;
		end
		else begin
		next_state <= curr_state;
		avs_o_s1_address_reg <= 32'd0;
		avs_o_s1_read_reg <= 1'b0;
		avs_o_s1_write_reg <= 1'b0;
		avs_o_s1_writedata_reg <= 32'd0;
		avs_p_s1_address_reg <= 32'd0;
		avs_p_s1_read_reg <= 1'b0;
		avs_p_s1_write_reg <= 1'b0;
		avs_p_s1_writedata_reg <= 32'd0;
		slv_reg3 <= slv_reg3;
		slv_reg2 <= slv_reg2;
		case(curr_state)
			//The initial state: waits for a signal from slv_reg1
			3'b000 : begin 
					if(slv_reg1 == 32'b1) begin
						slv_reg2 <= 32'd0;
						next_state <= 3'b001;
					end
				end
			//State that sets the input parameter
			3'b001 : begin 
					//Argument for the original circuit and slice
					avs_o_s1_address_reg <= 32'd3;
					avs_o_s1_writedata_reg <= slv_reg0;
					avs_o_s1_write_reg <= 1'b1;	
					avs_p_s1_address_reg <= 32'd3;
					avs_p_s1_writedata_reg <= slv_reg0;
					avs_p_s1_write_reg <= 1'b1;	
					next_state <= 3'b011;
				end
			//State that sets the start register of the pSlice 
			3'b011 :	begin 
					avs_p_s1_address_reg <= 32'd2;
					avs_p_s1_write_reg <= 1'b1;
					avs_p_s1_writedata_reg <= 32'd1;
					if(!fifo_empty)
						next_state <= 3'b100;
				end
			//State that sets the start register of the original circuit 
			3'b100 :	begin 
					avs_o_s1_address_reg <= 32'd2;
					avs_o_s1_write_reg <= 1'b1;
					avs_o_s1_writedata_reg <= 32'd1;
					next_state <= 3'b101;
				end
			//State that waits for the finish signal
			3'b101 : begin 
					if(legup_finish == 1) begin
						next_state <= 3'b110;
						slv_reg3 <= final_result;
					end
				end
			3'b110 : begin //notify sw hw has completed
					slv_reg2 <= 32'd1;
					next_state <= 3'b000;	
				end
			//The default condition should never occur
			default: next_state <= 3'b000;
		endcase
		end
	end	

	//##########################################################

        debug_pSlice_top dpt_pSlice_inst(
                .ru_finish(slice_finish),
                .csi_clockreset_clk(m_aclk),
                .csi_clockreset_reset(~m_aresetn),
                .avs_s1_address(avs_p_s1_address_reg),
                .avs_s1_read(avs_p_s1_read_reg),
                .avs_s1_write(avs_p_s1_write_reg),
                .avs_s1_writedata(avs_p_s1_writedata_reg),
                .avs_s1_readdata(avs_p_s1_readdata),
                .avm_ACCEL_readdata(avm_p_ACCEL_readdata),
                .avm_ACCEL_waitrequest(avm_p_ACCEL_waitrequest),
                .avm_ACCEL_address(avm_p_ACCEL_address),
                .avm_ACCEL_writedata(avm_p_ACCEL_writedata),
                .avm_ACCEL_write(avm_p_ACCEL_write),
                .avm_ACCEL_read(avm_p_ACCEL_read)
        );

	debug_top dpt_inst(
		.ru_res(final_result),
		.ru_finish(legup_finish),
		.csi_clockreset_clk(m_aclk),
		.csi_clockreset_reset(~m_aresetn),
		.avs_s1_address(avs_o_s1_address_reg),
		.avs_s1_read(avs_o_s1_read_reg),
		.avs_s1_write(avs_o_s1_write_reg),
		.avs_s1_writedata(avs_o_s1_writedata_reg),
		.avs_s1_readdata(avs_o_s1_readdata),
		.avm_ACCEL_readdata(avm_o_ACCEL_readdata),
		.avm_ACCEL_waitrequest(avm_o_ACCEL_waitrequest),
		.avm_ACCEL_address(avm_o_ACCEL_address),
		.avm_ACCEL_writedata(avm_o_ACCEL_writedata),
		.avm_ACCEL_write(avm_o_ACCEL_write),
		.avm_ACCEL_read(avm_o_ACCEL_read)
	);

	
	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      //slv_reg2 <= 0; //The location where the data is read from
	      //slv_reg3 <= 0; //debug register
	      //slv_reg4 <= 0;
	      //slv_reg5 <= 0;
	      //slv_reg6 <= 0;
	      //slv_reg7 <= 0;
	      //slv_reg8 <= 0;
	      slv_reg9 <= 0;
	      slv_reg10 <= 0;
	      slv_reg11 <= 0;
	      slv_reg12 <= 0;
	      slv_reg13 <= 0;
	      slv_reg14 <= 0;
	      slv_reg15 <= 0;
	      slv_reg16 <= 0;
	      slv_reg17 <= 0;
	      slv_reg18 <= 0;
	      slv_reg19 <= 0;
	      slv_reg20 <= 0;
	      slv_reg21 <= 0;
	      slv_reg22 <= 0;
	      slv_reg23 <= 0;
	      slv_reg24 <= 0;
	      slv_reg25 <= 0;
	      slv_reg26 <= 0;
	      slv_reg27 <= 0;
	      slv_reg28 <= 0;
	      slv_reg29 <= 0;
	      slv_reg30 <= 0;
	      slv_reg31 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          5'h00:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h01:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h02:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                //slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h03:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                //slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h04:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 4
	                //slv_reg4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h05:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 5
	                //slv_reg5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h06:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 6
	                //slv_reg6[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h07:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 7
	                //slv_reg7[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h08:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 8
	                //slv_reg8[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h09:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 9
	                slv_reg9[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h0A:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 10
	                slv_reg10[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h0B:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 11
	                slv_reg11[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h0C:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 12
	                slv_reg12[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h0D:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 13
	                slv_reg13[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h0E:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 14
	                slv_reg14[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h0F:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 15
	                slv_reg15[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h10:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 16
	                slv_reg16[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h11:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 17
	                slv_reg17[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h12:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 18
	                slv_reg18[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h13:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 19
	                slv_reg19[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h14:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 20
	                slv_reg20[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h15:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 21
	                slv_reg21[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h16:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 22
	                slv_reg22[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h17:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 23
	                slv_reg23[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h18:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 24
	                slv_reg24[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h19:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 25
	                slv_reg25[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h1A:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 26
	                slv_reg26[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h1B:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 27
	                slv_reg27[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h1C:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 28
	                slv_reg28[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h1D:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 29
	                slv_reg29[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h1E:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 30
	                slv_reg30[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h1F:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 31
	                slv_reg31[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      //slv_reg2 <= slv_reg2;
	                      //slv_reg3 <= slv_reg3;
	                      //slv_reg4 <= slv_reg4;
	                      //slv_reg5 <= slv_reg5;
	                      //slv_reg6 <= slv_reg6;
	                      //slv_reg7 <= slv_reg7;
	                      //slv_reg8 <= slv_reg8;
	                      slv_reg9 <= slv_reg9;
	                      slv_reg10 <= slv_reg10;
	                      slv_reg11 <= slv_reg11;
	                      slv_reg12 <= slv_reg12;
	                      slv_reg13 <= slv_reg13;
	                      slv_reg14 <= slv_reg14;
	                      slv_reg15 <= slv_reg15;
	                      slv_reg16 <= slv_reg16;
	                      slv_reg17 <= slv_reg17;
	                      slv_reg18 <= slv_reg18;
	                      slv_reg19 <= slv_reg19;
	                      slv_reg20 <= slv_reg20;
	                      slv_reg21 <= slv_reg21;
	                      slv_reg22 <= slv_reg22;
	                      slv_reg23 <= slv_reg23;
	                      slv_reg24 <= slv_reg24;
	                      slv_reg25 <= slv_reg25;
	                      slv_reg26 <= slv_reg26;
	                      slv_reg27 <= slv_reg27;
	                      slv_reg28 <= slv_reg28;
	                      slv_reg29 <= slv_reg29;
	                      slv_reg30 <= slv_reg30;
	                      slv_reg31 <= slv_reg31;
	                    end
	        endcase
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        5'h00   : reg_data_out <= slv_reg0;
	        5'h01   : reg_data_out <= slv_reg1;
	        5'h02   : reg_data_out <= slv_reg2;
	        5'h03   : reg_data_out <= slv_reg3;
	        5'h04   : reg_data_out <= slv_reg4;
	        5'h05   : reg_data_out <= slv_reg5;
	        5'h06   : reg_data_out <= slv_reg6;
	        5'h07   : reg_data_out <= slv_reg7;
	        5'h08   : reg_data_out <= slv_reg8;
	        5'h09   : reg_data_out <= slv_reg9;
	        5'h0A   : reg_data_out <= slv_reg10;
	        5'h0B   : reg_data_out <= slv_reg11;
	        5'h0C   : reg_data_out <= slv_reg12;
	        5'h0D   : reg_data_out <= slv_reg13;
	        5'h0E   : reg_data_out <= slv_reg14;
	        5'h0F   : reg_data_out <= slv_reg15;
	        5'h10   : reg_data_out <= slv_reg16;
	        5'h11   : reg_data_out <= slv_reg17;
	        5'h12   : reg_data_out <= slv_reg18;
	        5'h13   : reg_data_out <= slv_reg19;
	        5'h14   : reg_data_out <= slv_reg20;
	        5'h15   : reg_data_out <= slv_reg21;
	        5'h16   : reg_data_out <= slv_reg22;
	        5'h17   : reg_data_out <= slv_reg23;
	        5'h18   : reg_data_out <= slv_reg24;
	        5'h19   : reg_data_out <= slv_reg25;
	        5'h1A   : reg_data_out <= slv_reg26;
	        5'h1B   : reg_data_out <= slv_reg27;
	        5'h1C   : reg_data_out <= slv_reg28;
	        5'h1D   : reg_data_out <= slv_reg29;
	        5'h1E   : reg_data_out <= slv_reg30;
	        5'h1F   : reg_data_out <= slv_reg31;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here

	// User logic ends

	endmodule

module sync_fifo //synchronisation fifo.
   #(
      parameter DATA_WIDTH = 32,
      parameter LOG2_DEPTH = 1  // i.e. fifo depth=2**LOG2_DEPTH
   )
   (
      fifo_debug,
      din,
      wr_en,
      rd_en,
      dout,
      full,
      empty,
      clk,
      reset
   );

   input [DATA_WIDTH-1:0]  din;
   input wr_en;
   input rd_en;
   output reg [DATA_WIDTH-1:0] dout;
   output wire full;
   output wire empty;
   input clk;
   input reset;
   output reg [31:0] fifo_debug;

   parameter MAX_COUNT = 2**LOG2_DEPTH;
   reg   [LOG2_DEPTH-1 : 0]   rd_ptr;
   reg   [LOG2_DEPTH-1 : 0]   wr_ptr;
   reg   [DATA_WIDTH-1 : 0]   mem[MAX_COUNT-1 : 0];   //memory size: 2**LOG2_DEPTH
   reg   [LOG2_DEPTH : 0]     depth_cnt;

   always @(posedge clk) begin
      if(reset) begin
         wr_ptr <= 'h0;
         rd_ptr <= 'h0;
      end // end if
      else begin
         if(wr_en)begin
            wr_ptr <= wr_ptr+1;
         end
         if(rd_en) begin
            rd_ptr <= rd_ptr+1;
	 end
      end //end else
   end//end always

   //------------------DEBUGGING---------------------
   always @(posedge clk) begin
	if(reset) begin
		fifo_debug <= 32'd0;	
	end
	else begin
		if(rd_en)
			fifo_debug <= fifo_debug + mem[rd_ptr];
		//if(depth_cnt > fifo_debug)
		//	fifo_debug <= depth_cnt;
	end
   end
   //------------------------------------------------

   assign empty= (depth_cnt=='h0);
   assign full = (depth_cnt==MAX_COUNT);

   //comment if you want a registered dout
   //assign dout = rd_en ? mem[rd_ptr]:'h0;

   always @(posedge clk) begin
      if(reset) begin
      end
      else begin
      	if (wr_en) begin
      	   mem[wr_ptr] <= din;
      	end
      end //else end
   end //end always

   //uncomment if you want a registered dout
   always @(posedge clk) begin
      if (reset)
         dout <= 'h0;
      else if (rd_en)
         dout <= mem[rd_ptr];
   end

   always @(posedge clk) begin
      if (reset)
         depth_cnt <= 'h0;
      else begin
         case({rd_en,wr_en})
            2'b10    : begin
			  depth_cnt <= depth_cnt-1; 
		       end 
            2'b01    : begin
			  depth_cnt <= depth_cnt+1; 
		       end
         endcase
      end //end else
   end //end always

endmodule
