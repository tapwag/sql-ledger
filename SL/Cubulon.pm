#=====================================================================
# SQL-Ledger ERP
# Copyright (C) 2015
#
#  Author: Tekki at Cubulon
#     Web: https://cubulon.ch
#
#  Version: 0.3
#
#======================================================================
#
# Cubulon connector
#
#======================================================================

package Cubulon;

sub add_reference {
  my ($self, $myconfig, $form) = @_;

  if ($form->{id} and $form->{referenceid} and $form->{referencedescription}) {
    my $dbh = $form->dbconnect($myconfig);
    my $query
      = q|INSERT INTO reference (id, trans_id, description) VALUES (?,?,?)|;
    my $sth = $dbh->prepare($query) || $form->dberror($query);
    $sth->execute($form->{referenceid}, $form->{id},
      $form->{referencedescription})
      || $form->dberror($query);

    $form->{result} = 'success';
  } else {
    $form->{result} = 'error';
  }
}

sub find_invoice {
  my ($self, $myconfig, $form) = @_;

  my $dbh   = $form->dbconnect($myconfig);
  my $where = '1 = 0';

  if ($form->{id}) {
    $where = 'id = ' . $dbh->quote($form->{id});
    delete $form->{id};
  } elsif ($form->{dcn}) {
    $where = 'dcn = ' . $dbh->quote($form->{dcn});
  } elsif ($form->{invnumber}) {
    $where = 'invnumber = ' . $dbh->quote($form->{invnumber});
  }

  my $query = qq|SELECT id, customer_id FROM ar WHERE $where|;

  if (my $ref = $dbh->selectrow_arrayref($query)) {
    ($form->{id}, $form->{customer_id}) = @$ref;
  }

}

sub list_accounts {
  my ($self, $myconfig, $form) = @_;

  my $dbh = $form->dbconnect($myconfig);

  my $query = q|SELECT * FROM chart WHERE charttype='A' ORDER BY accno|;
  my $sth = $dbh->prepare($query) || $form->dberror($query);
  $sth->execute;

  my $ref;
  while ($ref = $sth->fetchrow_hashref(NAME_lc)) {
    push @{$form->{accounts}}, $ref;
  }
}

1;
