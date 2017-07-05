package org.oscarehr.common.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

/*
* David Bond - 2017-06-09
* Rx Manager created for future usage. As additional features are added,  
* add their accessors/mutators here and update the `rxmanage` table.
*/

@Entity
@Table(name="rxmanage")
public class RxManage extends AbstractModel<Integer>
{
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name="provider_no")
    private String providerNo;

    @Column(name="mrpOnRx")
    private Boolean mrpOnRx;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getProviderNo() {
        return providerNo;
    }

    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    public Boolean getMrpOnRx() {
        return mrpOnRx;
    }

    public void setMrpOnRx(Boolean mrpOnRx) {
        this.mrpOnRx = mrpOnRx;
    }
    
}
