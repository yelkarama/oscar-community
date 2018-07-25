ALTER TABLE billing_on_payment ADD active boolean DEFAULT true NULL;

UPDATE billing_on_payment SET billing_on_payment.active = false 
where total_payment = 0.00 and total_discount = 0.00 and total_refund = 0.00 and total_credit = 0.00;