package org.oscarehr.common.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name="referral_source")
public class ReferralSource extends AbstractModel<Integer> implements Serializable {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name="referral_source")
    private String referralSource;

    @Column(name="last_update_user")
    private Integer lastUpdateUser;

    @Column(name="last_update_date")
    private Date lastUpdateDate;

    @Column(name="archived")
    private Boolean archiveStatus;

    public ReferralSource () {}

    public Integer getId() {return id;}

    public String getReferralSource () {return referralSource;}

    public void setReferralSource (String referralSource) {this.referralSource=referralSource;}

    public Integer getLastUpdateUser () {return lastUpdateUser;}

    public void setLastUpdateUser (Integer lastUpdateUser) {this.lastUpdateUser=lastUpdateUser;}

    public Date getLastUpdateDate () {return lastUpdateDate;}

    public void setLastUpdateDate (Date lastUpdateDate) {this.lastUpdateDate=lastUpdateDate;}

    public Boolean getArchiveStatus () {return archiveStatus;}

    public void setArchiveStatus (Boolean archiveStatus) {this.archiveStatus=archiveStatus;}
}
