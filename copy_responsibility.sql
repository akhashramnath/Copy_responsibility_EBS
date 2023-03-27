SQL> declare
res_user_name		varchar2(100);
res_app_sn         	varchar2(200);
res_respkey        	varchar2(200);
res_sgkey          	varchar2(200);
res_desc           	varchar2(200);
res_name           	varchar2(200);

cursor usrname is select user_name from fnd_user where user_name in ('SAMPLE3'); /*Mention the user who needs the responsibility, Target Username*/------- Target User

cursor respname is
SELECT fa.application_short_name,fr.responsibility_key,frg.security_group_key,frt.description,frt.responsibility_name
FROM apps.fnd_responsibility fr,apps.fnd_application fa,apps.fnd_security_groups frg,apps.fnd_responsibility_tl frt
WHERE fr.application_id = fa.application_id
AND    fr.data_group_id = frg.security_group_id
AND    fr.responsibility_id = frt.responsibility_id
AND    frt.LANGUAGE = 'US'
AND    frt.responsibility_name in
(SELECT frtl.responsibility_name
FROM apps.fnd_user_resp_groups_direct furd, apps.fnd_responsibility_tl frtl
WHERE furd.responsibility_id = frtl.responsibility_id
AND furd.user_id IN ( SELECT user_id FROM apps.fnd_user WHERE user_name='SAMPLE2' ) /*Mention the user who already has the responsibility, Source Username*/------- Target User-------- Source User
AND (furd.end_date is null)
and frtl.LANGUAGE = 'US');

begin

open usrname; 
loop
fetch usrname into res_user_name;
exit when usrname%notfound;

open respname;
loop
fetch respname into res_app_sn,res_respkey,res_sgkey,res_desc,res_name;
exit when respname%notfound;
fnd_user_pkg.addresp (username          	=> res_user_name,
                      resp_app           	=> res_app_sn,
					  resp_key            	=> res_respkey,
                      security_group 		=> res_sgkey,
                      description        	=> res_desc,
                      start_date          	=> SYSDATE,
                      end_date            	=> NULL
                     );
commit;
end loop;
close respname;

end loop;
close usrname;
end;
/
