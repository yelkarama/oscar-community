package org.oscarehr.common.model;


import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name="userAcceptance")
public class UserAcceptance extends AbstractModel<Integer>
{
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;

    @Column(name = "accepted")
    private boolean accepted;

    @Column(name = "providerNo")
    private String providerNo;

    @Column(name = "timeAccepted")
    private Date timeAccepted;

    @Override
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public boolean isAccepted() {
        return accepted;
    }

    public void setAccepted(boolean accepted) {
        this.accepted = accepted;
    }

    public String getProviderNo() {
        return providerNo;
    }

    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    public Date getTimeAccepted() {
        return timeAccepted;
    }

    public void setTimeAccepted(Date timeAccepted) {
        this.timeAccepted = timeAccepted;
    }
}
