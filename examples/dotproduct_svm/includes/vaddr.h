#ifndef __VADDR_H__
#define __VADDR_H__

#define PAGE_SIZE 4095
#define NUMPAGES 2

unsigned * L1_table_lookup(unsigned offset, unsigned *l1_pagetable)
{
        unsigned *pageAddr = *(volatile unsigned*)(l1_pagetable + offset/4);
        return pageAddr;
}

unsigned * pageLookup(unsigned *pageAddr, unsigned offset)
{
        unsigned *physAddr = *(volatile unsigned*)(pageAddr + offset/4);
        return physAddr;
}


unsigned * virt2phys(volatile unsigned *vaddr, unsigned *l1_pagetable){
        unsigned pageNum = ((unsigned)vaddr & 0x00FFF000) >> 12;
        unsigned pageOffset = ((unsigned)vaddr & 0x00000FFF);

        unsigned *pageAddr = L1_table_lookup(pageNum, l1_pagetable);
        unsigned *paddr = pageLookup(pageAddr, pageOffset);
        return paddr;
}

void write2virt(volatile unsigned *vaddr, int val, unsigned * l1_pagetable) {
        unsigned *paddr = virt2phys(vaddr, l1_pagetable);
        *paddr = val;
        return;
}

int readVirt(unsigned *vaddr, unsigned * l1_pagetable){
        unsigned *paddr = virt2phys(vaddr, l1_pagetable);
        return *paddr;
}

void setupPageTables(unsigned * l1_pagetable, unsigned *paddr_start, unsigned *page_start){
        unsigned * assigned_paddr = paddr_start;
        //setup L1 page table
        for(int i=0; i <NUMPAGES; i++) {
                unsigned *pageAddr = page_start + (PAGE_SIZE/4)*i;
                *(l1_pagetable + i) = pageAddr;
                for(int j=0; j<(PAGE_SIZE/4); j++) {
                        *(pageAddr + j) = assigned_paddr;
                        assigned_paddr = assigned_paddr + j;
                }
        }
}


#endif
