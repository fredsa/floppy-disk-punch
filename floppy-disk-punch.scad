// https://web.archive.org/web/20190603181532/http://www.ecma-international.org/publications/files/ECMA-ST-WITHDRAWN/ECMA-66,%201st%20Edition,%20September%201980.pdf

delta=0.01;

in2mm=25.4;

floppy_xy=133.3; // 133.3 ± 0.4 (5.25")
floppy_z=2.2; // 1.2 … 2.1

notch_inset=3.8; // 3.8 ± 0.2
notch_pos1=96.5; // 96.5 ± 0.2
notch_pos2=102.8; // 102.8 ± 0.2
notch_w=notch_pos2-notch_pos1; // 1/4"

tool_x=20;
tool_y=floppy_xy-notch_pos1+15;

bottom_plate_z=4;
top_plate_z=2;

wall=2;

punch_l=41;
punch_x=7;
punch_y=notch_w;
punch_min_z=1;

punch_head_l=15;
punch_head_lid_z=5;
punch_head_lid_overhang=3;
punch_head_lid_r=2;

stack_l=punch_l-bottom_plate_z-floppy_z-top_plate_z+punch_min_z-punch_head_l;

metal_z=.5;

shaft_overhang=punch_x-notch_inset;

explode=2;
print_d=5;

module tool_block(print) {
    // Base plate.
    cube([tool_x, tool_y, bottom_plate_z-metal_z]);

    if (!print) {
        // Metal insert.
    %   difference() {
            translate([0,0,bottom_plate_z-metal_z+delta])
            cube([tool_x-wall-delta, tool_y-wall-delta, metal_z-delta]);

            translate([tool_x-notch_inset-wall, notch_pos1-floppy_xy+tool_y, -delta])
            cube([notch_inset+wall+delta, notch_w, bottom_plate_z+floppy_z+top_plate_z+2*delta]);
        }
    }

    // Walls.
    translate([tool_x-wall, 0, bottom_plate_z-metal_z])
    cube([wall, tool_y, floppy_z+metal_z]);

    translate([0, tool_y-wall, bottom_plate_z-metal_z])
    cube([tool_x, wall, floppy_z+metal_z]);

    // Top plate.
    translate([0, 0, bottom_plate_z+floppy_z])
    cube([tool_x, tool_y, top_plate_z]);

    //Stack.
    difference() {
        translate([tool_x-notch_inset-2*wall, notch_pos1-floppy_xy+tool_y-wall, bottom_plate_z+floppy_z+top_plate_z])
        cube([punch_x+2*wall, punch_y+2*wall, stack_l]);

        translate([tool_x-notch_inset-wall, notch_pos1-floppy_xy+tool_y, bottom_plate_z+floppy_z+top_plate_z-delta])
        cube([punch_x, punch_y, stack_l+2*delta]);
    }
}


module tool(print) {
    difference() {
        tool_block(print);

        // Cut out for punch.
        translate([tool_x-notch_inset-wall, notch_pos1-floppy_xy+tool_y, -delta])
        cube([notch_inset+wall+delta, notch_w, bottom_plate_z+floppy_z+top_plate_z+2*delta]);
    }
}

module punch() {
    #difference() {
        cube([punch_x, punch_y, punch_l]);

        rotate([0, -20, 0])
        translate([-punch_x/2, -punch_y/2, -4])
            cube([punch_x*2, punch_y*2, 4]);
    }
}

module punch_head() {
    union() {
        difference() {
            // Shaft.
            cube([punch_x+2*wall, punch_y+2*wall, punch_head_l]);

            // Remove.
            translate([wall, wall, -delta])
            cube([punch_x, punch_y, stack_l+2*delta]);
        }

        // Head.
        translate([-punch_head_lid_overhang, -punch_head_lid_overhang, punch_head_l])
        minkowski($fn=20) {
            cube([punch_x+2*wall+2*punch_head_lid_overhang, punch_y+2*wall+2*punch_head_lid_overhang, punch_head_lid_z]);
            sphere(punch_head_lid_r);
        }
    }
}

module everything(print) {
    if (print) {
        translate([0, 0, tool_x+shaft_overhang])
        rotate([0, 90, 0])
        tool(print);

        translate([0, -print_d, 0])
        translate([punch_head_lid_overhang+punch_head_lid_r, -punch_head_lid_overhang-punch_head_lid_r, punch_head_l+punch_head_lid_z+punch_head_lid_r])
        rotate([180,0,0])
        punch_head();
    } else {
        tool(print);

        translate([tool_x-notch_inset-wall, notch_pos1-floppy_xy+tool_y, punch_min_z])
        punch();

        translate([0,0,explode])
        translate([tool_x-notch_inset-2*wall, notch_pos1-floppy_xy+tool_y-wall, bottom_plate_z+floppy_z+top_plate_z+stack_l])
        punch_head();
    }
}

everything(print=!false);

